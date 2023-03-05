#import "Basic"; //()(MEMORY_DEBUGGER=true);
#import "String";

#scope_module

sound_player : *Sound_Player;

audio_init :: () {
    sound_player = New(Sound_Player);
    sound_player.update_history = true;    
}

audio_update :: () {
    //
    // Move sound streams forward by dt.
    //
    lock(*sound_player.sound_mutex);
    defer unlock(*sound_player.sound_mutex);

    pre_entity_update(sound_player);

    //
    // @Incomplete We're not removing sound streams once they're consumed.
    //
    for sound_player.streams {
        it.marked = true;
    }

    post_entity_update(sound_player, time_delta);
}

audio_play_music :: (name: string) {
    data := load_audio_file(name);

    if !data {
        print("Could not load theme music: %\n", name);
        exit(1);
    }

    stream := audio_play_sound(data, false);

    if stream {
        stream.flags |= .REPEATING;
        stream.category = .MUSIC;
        stream.user_volume_scale *= 1.0;
    }
}

audio_play_sound :: (data: *Mixer_Sound_Data, perturb: bool = true) -> *Sound_Stream {
    stream := make_stream(sound_player, data);

    if stream {
        stream.sound_data = data;
    }

    if perturb && stream {
        stream.user_volume_scale = random_get_within_range(0.7, 1);
        stream.desired_rate = random_get_within_range(0.7, 1.22);
    }

    stream.repeat_end_position = cast(int)(cast(float)(data.nsamples_times_nchannels / data.nchannels));
    
    return stream;
}

#scope_file

music_data : *Mixer_Sound_Data;
music_stream : *Sound_Stream;

load_audio_file :: (name : string) -> *Mixer_Sound_Data {
    data : *Mixer_Sound_Data = null;

    file_data, success := read_entire_file(name);
    if !success return data;

    has_extension :: (name: string, extension: string) -> bool {
        if name.count < extension.count  return false;
        test := name;
        advance(*test, name.count - extension.count);
        return test == extension;
    }

    if has_extension(name, "wav") {
        data = New(Mixer_Sound_Data);
        data.name = copy_string(name);
        data.buffer = file_data;

        format, samples, success2, extra := get_wav_header(data.buffer);
        if !success2 {
            log_error("Unable to parse '%' as wav.\n", data.full_path);
            return data;
        }

        if format.wFormatTag == WAVE_FORMAT_PCM {
            data.type                     = .LINEAR_SAMPLE_ARRAY;
            data.nchannels                = cast(u16) format.nChannels;
            data.nsamples_times_nchannels = samples.count/2;
        } else if format.wFormatTag == WAVE_FORMAT_DVI_ADPCM {
            data.type             = .ADPCM_COMPRESSED;
            data.wSamplesPerBlock = extra.wSamplesPerBlock;
            data.nBlockAlign      = format.nBlockAlign;

            data.nchannels = cast(u16) format.nChannels;
            // The value in the FACT chunk is number of samples by time. 
            data.nsamples_times_nchannels = extra.wSamplesAccordingToFactChunk * data.nchannels;
        } else {
            assert(false);
        }

        data.samples       = cast(*s16) samples.data;
        data.sampling_rate = cast(u32) format.nSamplesPerSec;
    } else if has_extension(name, "ogg") {
        data = New(Mixer_Sound_Data);
        data.name   = copy_string(name);
        data.buffer = file_data;
        data.type   = .OGG_COMPRESSED;
    } else {
        // Unsupported format.
    }

    return data;
}

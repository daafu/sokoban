#import "Basic"; //()(MEMORY_DEBUGGER=true);
#import "String";

#scope_module

sound_player : *Sound_Player;
music_stream : *Sound_Stream;
music_base_volume : float = 1;

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

    if music_stream {
        music_stream.user_volume_scale = music_base_volume * options_get_music_volume();
    }

    post_entity_update(sound_player, time_delta);
}

audio_play_music :: (name: string, volume: float) {
    data := audio_load(name);

    if !data {
        print("Could not load theme music: %\n", name);
        exit(1);
    }

    music_stream = audio_play_sound(data, false);

    if music_stream {
        music_base_volume = volume;

        music_stream.flags |= .REPEATING;
        music_stream.category = .MUSIC;
        music_stream.user_volume_scale = music_base_volume * options_get_music_volume();
    }
}

audio_play_sound :: (data: *Mixer_Sound_Data, perturb: bool = true) -> *Sound_Stream {
    if options_get_sfx_volume() == 0 {
        return null;
    }

    stream := make_stream(sound_player, data);

    if stream {
        stream.sound_data = data;
    }

    if perturb && stream {
        stream.user_volume_scale = random_get_within_range(0.9, 1);
        stream.desired_rate = random_get_within_range(0.9, 1.1);
    }

    stream.user_volume_scale *= options_get_sfx_volume();

    stream.repeat_end_position = cast(int)(cast(float)(data.nsamples_times_nchannels / data.nchannels));
    
    return stream;
}

audio_load :: (name : string) -> *Mixer_Sound_Data {
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

#scope_file

music_data : *Mixer_Sound_Data;
music_stream : *Sound_Stream;


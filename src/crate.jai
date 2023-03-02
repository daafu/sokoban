#import "Basic"; //()(MEMORY_DEBUGGER=true);

Crate :: struct {
    #as using base: Entity; 
    base.type = .CRATE;
    base.spr = .CRATE;
    base.color = 5;
    base.flags = xx EntityFlags.PUSHABLE;
}

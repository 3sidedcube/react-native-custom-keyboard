
#import "RNCustomKeyboard.h"
#import <React/RCTBridge+Private.h>
#import <React/RCTUIManager.h>
#import <React/RCTUIManager.h>
#import "RNCustomKeyboardRootView.h"
#import <React/RCTEventDispatcher.h>
#import "RCTTextView.h"
#import "RCTTextField.h"

@implementation RNCustomKeyboard

@synthesize bridge = _bridge;

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE(CustomKeyboard)

RCT_EXPORT_METHOD(install:(nonnull NSNumber *)reactTag withType:(nonnull NSString *)keyboardType passProps:(NSDictionary *)passProps type:(NSString *)type)
{
    NSMutableDictionary *props = passProps ? [passProps mutableCopy] : @{};
    [props setValue:reactTag forKey:@"tag"];
    [props setValue:keyboardType forKey:@"type"];
    
    UITextView *view = (UITextView*)[_bridge.uiManager viewForReactTag:reactTag];

    if (type && [type isEqualToString:@"input"]) {
        
        UIView* inputView = [[RNCustomKeyboardRootView alloc] initWithBridge:((RCTBatchedBridge *)_bridge).parentBridge moduleName:@"CustomKeyboard" initialProperties:props];
        view.inputView = inputView;
        
    } else if (type && [type isEqualToString:@"accessory"]) {
        
        UIView *accessoryView = [[RNCustomKeyboardRootView alloc] initWithBridge:((RCTBatchedBridge *)_bridge).parentBridge moduleName:@"CustomAccessory" initialProperties:props];
        CGRect frame = accessoryView.frame;
        frame.size = CGSizeMake(frame.size.width, 44);
        accessoryView.frame = frame;
        view.inputAccessoryView = accessoryView;
    }

    [view reloadInputViews];
}

RCT_EXPORT_METHOD(uninstall:(nonnull NSNumber *)reactTag type:(NSString *)type)
{
    UITextView *view = (UITextView*)[_bridge.uiManager viewForReactTag:reactTag];

    if (type && [type isEqualToString:@"input"]) {
        
        view.inputView = nil;
        
    } else if (type && [type isEqualToString:@"accessory"]) {
        
        view.inputAccessoryView = nil;
    }
    
    [view reloadInputViews];
}

RCT_EXPORT_METHOD(insertText:(nonnull NSNumber *)reactTag withText:(NSString*)text) {
    UITextView *view = (UITextView*)[_bridge.uiManager viewForReactTag:reactTag];

    [view replaceRange:view.selectedTextRange withText:text];
}

RCT_EXPORT_METHOD(clear:(nonnull NSNumber *)reactTag) {
    UITextView *view = (UITextView *)[_bridge.uiManager viewForReactTag:reactTag];
    view.text = nil;
}

RCT_EXPORT_METHOD(replaceText:(nonnull NSNumber *)reactTag withText:(NSString*)text) {
    UITextView *view = (UITextView*)[_bridge.uiManager viewForReactTag:reactTag];
    
    UITextRange *wholeRange = [view textRangeFromPosition:view.beginningOfDocument toPosition:view.endOfDocument];
    // Have to do this to get correct behaviour in RN
    if (wholeRange) {
        [view replaceRange:wholeRange withText:text];
    } else {
        view.text = text;
    }
}

RCT_EXPORT_METHOD(submit:(nonnull NSNumber *)reactTag) {
    UITextView *view = (UITextView *)[_bridge.uiManager viewForReactTag:reactTag];
    
    if ([view isKindOfClass:[RCTTextView class]]) {
        
        RCTTextView *rctView = (RCTTextView *)view;
        if ([rctView respondsToSelector:@selector(eventDispatcher)]) {
            RCTEventDispatcher *eventDispatcher = [rctView performSelector:@selector(eventDispatcher)];
            [eventDispatcher sendTextEventWithType:RCTTextEventTypeSubmit reactTag:reactTag text:view.text key:nil eventCount:0];
        }
    } else if ([view isKindOfClass:[RCTTextField class]]) {
        
        if ([view respondsToSelector:@selector(textFieldSubmitEditing)]) {
            [view performSelector:@selector(textFieldSubmitEditing)];
        }
    }
    
    [view resignFirstResponder];
}

RCT_EXPORT_METHOD(backSpace:(nonnull NSNumber *)reactTag) {
    UITextView *view = (UITextView*)[_bridge.uiManager viewForReactTag:reactTag];

    UITextRange* range = view.selectedTextRange;
    if ([view comparePosition:range.start toPosition:range.end] == 0) {
    range = [view textRangeFromPosition:[view positionFromPosition:range.start offset:-1] toPosition:range.start];
    }
    [view replaceRange:range withText:@""];
}

RCT_EXPORT_METHOD(doDelete:(nonnull NSNumber *)reactTag) {
    UITextView *view = (UITextView*)[_bridge.uiManager viewForReactTag:reactTag];

    UITextRange* range = view.selectedTextRange;
    if ([view comparePosition:range.start toPosition:range.end] == 0) {
    range = [view textRangeFromPosition:range.start toPosition:[view positionFromPosition: range.start offset: 1]];
    }
    [view replaceRange:range withText:@""];
}

RCT_EXPORT_METHOD(moveLeft:(nonnull NSNumber *)reactTag) {
    UITextView *view = (UITextView*)[_bridge.uiManager viewForReactTag:reactTag];

    UITextRange* range = view.selectedTextRange;
    UITextPosition* position = range.start;

    if ([view comparePosition:range.start toPosition:range.end] == 0) {
        position = [view positionFromPosition: position offset: -1];
    }

    view.selectedTextRange = [view textRangeFromPosition: position toPosition:position];
}

RCT_EXPORT_METHOD(moveRight:(nonnull NSNumber *)reactTag) {
    UITextView *view = (UITextView*)[_bridge.uiManager viewForReactTag:reactTag];

    UITextRange* range = view.selectedTextRange;
    UITextPosition* position = range.end;

    if ([view comparePosition:range.start toPosition:range.end] == 0) {
        position = [view positionFromPosition: position offset: 1];
    }

    view.selectedTextRange = [view textRangeFromPosition: position toPosition:position];
}

RCT_EXPORT_METHOD(switchSystemKeyboard:(nonnull NSNumber*) reactTag) {
    UITextView *view = (UITextView *)[_bridge.uiManager viewForReactTag:reactTag];
    UIView* inputView = view.inputView;
    view.inputView = nil;
    [view reloadInputViews];
    view.inputView = inputView;
}

@end
  

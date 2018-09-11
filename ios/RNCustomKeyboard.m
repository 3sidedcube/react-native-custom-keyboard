
#import "RNCustomKeyboard.h"
#import <React/RCTBridge+Private.h>
#import <React/RCTUIManager.h>
#import "RNCustomKeyboardRootView.h"
#import <React/RCTEventDispatcher.h>

@interface RCTUIManager (TextField)

- (UITextField * _Nullable)textFieldForReactTag:(NSNumber *)reactTag;

- (UITextView * _Nullable)textViewForReactTag:(NSNumber *)reactTag;

@end

@implementation RCTUIManager (TextField)

- (UITextView *)textViewForReactTag:(NSNumber *)reactTag
{
	UIView *view = [self viewForReactTag:reactTag];
	__block UITextView *textView;
	
	if ([view isKindOfClass:[UITextView class]]) {
		
		textView = (UITextView *)view;
		
	} else {
		
		[view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
			if ([obj isKindOfClass:[UITextView class]]) {
				textView = (UITextView *)obj;
				*stop = true;
			}
		}];
	}
	
	return textView;
}

- (UITextField *)textFieldForReactTag:(NSNumber *)reactTag
{
	UIView *view = [self viewForReactTag:reactTag];
	__block UITextField *textField;
	
	if ([view isKindOfClass:[UITextField class]]) {
		
		textField = (UITextField *)view;
		
	} else {
		
		[view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
			if ([obj isKindOfClass:[UITextField class]]) {
				textField = (UITextField *)obj;
				*stop = true;
			}
		}];
	}
	
	return textField;
}

@end

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
    
	UITextView *textView = [_bridge.uiManager textViewForReactTag:reactTag];
	UITextField *textField = [_bridge.uiManager textFieldForReactTag:reactTag];

    if (type && [type isEqualToString:@"input"]) {
        
        UIView* inputView = [[RNCustomKeyboardRootView alloc] initWithBridge:(_bridge).parentBridge moduleName:@"CustomKeyboard" initialProperties:props];
		
		inputView.translatesAutoresizingMaskIntoConstraints = false;
        textView.inputView = inputView;
        textField.inputView = inputView;
        
    } else if (type && [type isEqualToString:@"accessory"]) {
        
        UIView *accessoryView = [[RNCustomKeyboardRootView alloc] initWithBridge:(_bridge).parentBridge moduleName:@"CustomAccessory" initialProperties:props];
        CGRect frame = accessoryView.frame;
        frame.size = CGSizeMake(frame.size.width, 44);
        accessoryView.frame = frame;
        textView.inputAccessoryView = accessoryView;
        textField.inputAccessoryView = accessoryView;
    }

    [textView reloadInputViews];
	[textField reloadInputViews];
}

RCT_EXPORT_METHOD(uninstall:(nonnull NSNumber *)reactTag type:(NSString *)type)
{
	UITextView *textView = [_bridge.uiManager textViewForReactTag:reactTag];
	UITextField *textField = [_bridge.uiManager textFieldForReactTag:reactTag];

    if (type && [type isEqualToString:@"input"]) {
        
        textField.inputView = nil;
		textView.inputView = nil;
        
    } else if (type && [type isEqualToString:@"accessory"]) {
        
        textField.inputAccessoryView = nil;
		textView.inputAccessoryView = nil;
    }
    
    [textView reloadInputViews];
	[textField reloadInputViews];
}

RCT_EXPORT_METHOD(insertText:(nonnull NSNumber *)reactTag withText:(NSString*)text) {
	
	UITextView *textView = [_bridge.uiManager textViewForReactTag:reactTag];
	UITextField *textField = [_bridge.uiManager textFieldForReactTag:reactTag];
	
	if (textField) {
		[textField replaceRange:textField.selectedTextRange withText:text];
	}
	if (textView) {
		[textView replaceRange:textView.selectedTextRange withText:text];
	}
}

RCT_EXPORT_METHOD(clear:(nonnull NSNumber *)reactTag) {
	
	UITextView *textView = [_bridge.uiManager textViewForReactTag:reactTag];
	UITextField *textField = [_bridge.uiManager textFieldForReactTag:reactTag];
	
	textField.text = nil;
	textView.text = nil;
}

RCT_EXPORT_METHOD(replaceText:(nonnull NSNumber *)reactTag withText:(NSString*)text) {
	
	UITextView *textView = [_bridge.uiManager textViewForReactTag:reactTag];
	UITextField *textField = [_bridge.uiManager textFieldForReactTag:reactTag];
	
	if (textField) {
		
		UITextRange *wholeRange = [textField textRangeFromPosition:textField.beginningOfDocument toPosition:textField.endOfDocument];
		// Have to do this to get correct behaviour in RN
		if (wholeRange) {
			[textField replaceRange:wholeRange withText:text];
		} else {
			textField.text = text;
		}
		
	} else if (textView) {
		
		UITextRange *wholeRange = [textView textRangeFromPosition:textView.beginningOfDocument toPosition:textView.endOfDocument];
		// Have to do this to get correct behaviour in RN
		if (wholeRange) {
			[textView replaceRange:wholeRange withText:text];
		} else {
			textView.text = text;
		}
	}
}

RCT_EXPORT_METHOD(submit:(nonnull NSNumber *)reactTag) {
	
    UIView *view = (UIView *)[_bridge.uiManager viewForReactTag:reactTag];
    
    if ([view isKindOfClass:[UITextView class]]) {
        
        UITextView *rctView = (UITextView *)view;
        UITextView *textView = [_bridge.uiManager textViewForReactTag:reactTag];
		
        [self.bridge.eventDispatcher sendTextEventWithType:RCTTextEventTypeSubmit reactTag:reactTag text:textView.text key:nil eventCount:0];
		[rctView resignFirstResponder];
		
    } else if ([view isKindOfClass:[UITextField class]]) {
		
		UITextField *textField = [_bridge.uiManager textFieldForReactTag:reactTag];
		
		[self.bridge.eventDispatcher sendTextEventWithType:RCTTextEventTypeSubmit reactTag:reactTag text:textField.text key:nil eventCount:0];
		[textField resignFirstResponder];
    }    
}

RCT_EXPORT_METHOD(backSpace:(nonnull NSNumber *)reactTag) {
	
	UITextView *textView = [_bridge.uiManager textViewForReactTag:reactTag];
	UITextField *textField = [_bridge.uiManager textFieldForReactTag:reactTag];

	if (textView) {
		
		UITextRange* range = textView.selectedTextRange;
		if ([textView comparePosition:range.start toPosition:range.end] == 0) {
			range = [textView textRangeFromPosition:[textView positionFromPosition:range.start offset:-1] toPosition:range.start];
		}
		[textView replaceRange:range withText:@""];
	}
	
	if (textField) {
		
		UITextRange* range = textField.selectedTextRange;
		if ([textField comparePosition:range.start toPosition:range.end] == 0) {
			range = [textField textRangeFromPosition:[textField positionFromPosition:range.start offset:-1] toPosition:range.start];
		}
		[textField replaceRange:range withText:@""];
	}
}

RCT_EXPORT_METHOD(doDelete:(nonnull NSNumber *)reactTag) {
	
	UITextView *textView = [_bridge.uiManager textViewForReactTag:reactTag];
	UITextField *textField = [_bridge.uiManager textFieldForReactTag:reactTag];
	
	if (textView) {
		
		UITextRange* range = textView.selectedTextRange;
		if ([textView comparePosition:range.start toPosition:range.end] == 0) {
			range = [textView textRangeFromPosition:range.start toPosition:[textView positionFromPosition: range.start offset: 1]];
		}
		[textView replaceRange:range withText:@""];
	}
	
	if (textField) {
		
		UITextRange* range = textField.selectedTextRange;
		if ([textField comparePosition:range.start toPosition:range.end] == 0) {
			range = [textField textRangeFromPosition:range.start toPosition:[textField positionFromPosition: range.start offset: 1]];
		}
		[textField replaceRange:range withText:@""];
	}
}

RCT_EXPORT_METHOD(moveLeft:(nonnull NSNumber *)reactTag) {
	
	UITextView *textView = [_bridge.uiManager textViewForReactTag:reactTag];
	UITextField *textField = [_bridge.uiManager textFieldForReactTag:reactTag];
	
	if (textView) {
		
		UITextRange* range = textView.selectedTextRange;
		UITextPosition* position = range.start;
		
		if ([textView comparePosition:range.start toPosition:range.end] == 0) {
			position = [textView positionFromPosition: position offset: -1];
		}
		
		textView.selectedTextRange = [textView textRangeFromPosition: position toPosition:position];
	}

	if (textField) {
		
		UITextRange* range = textField.selectedTextRange;
		UITextPosition* position = range.start;
		
		if ([textField comparePosition:range.start toPosition:range.end] == 0) {
			position = [textField positionFromPosition: position offset: -1];
		}
		
		textField.selectedTextRange = [textField textRangeFromPosition: position toPosition:position];
	}
}

RCT_EXPORT_METHOD(moveRight:(nonnull NSNumber *)reactTag) {
	
	UITextView *textView = [_bridge.uiManager textViewForReactTag:reactTag];
	UITextField *textField = [_bridge.uiManager textFieldForReactTag:reactTag];
	
	if (textView) {
		
		UITextRange* range = textView.selectedTextRange;
		UITextPosition* position = range.end;
		
		if ([textView comparePosition:range.start toPosition:range.end] == 0) {
			position = [textView positionFromPosition: position offset: 1];
		}
		
		textView.selectedTextRange = [textView textRangeFromPosition: position toPosition:position];
	}
	
	if (textField) {
		
		UITextRange* range = textField.selectedTextRange;
		UITextPosition* position = range.end;
		
		if ([textField comparePosition:range.start toPosition:range.end] == 0) {
			position = [textField positionFromPosition: position offset: 1];
		}
		
		textField.selectedTextRange = [textField textRangeFromPosition: position toPosition:position];
	}
}

RCT_EXPORT_METHOD(switchSystemKeyboard:(nonnull NSNumber*) reactTag) {
	
	UITextView *textView = [_bridge.uiManager textViewForReactTag:reactTag];
	UITextField *textField = [_bridge.uiManager textFieldForReactTag:reactTag];
	
	if (textView) {
		
		UIView *inputView = textView.inputView;
		inputView.translatesAutoresizingMaskIntoConstraints = false;
		textView.inputView = nil;
		[textView reloadInputViews];
		textView.inputView = inputView;
	}
	
	if (textField) {
		
		UIView *inputView = textField.inputView;
		inputView.translatesAutoresizingMaskIntoConstraints = false;
		textField.inputView = nil;
		[textField reloadInputViews];
		textField.inputView = inputView;
	}
}

@end
  

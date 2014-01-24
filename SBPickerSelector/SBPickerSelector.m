//
//  SBPickerSelector.m
//  SBPickerSelector
//
//  Created by Santiago Bustamante on 1/24/14.
//  Copyright (c) 2014 Busta117. All rights reserved.
//

#import "SBPickerSelector.h"

@implementation SBPickerSelector


+ (SBPickerSelector *) picker {
    SBPickerSelector *instance = [[SBPickerSelector alloc] initWithNibName:@"SBPickerSelector" bundle:nil];
    instance.pickerData = [NSMutableArray arrayWithCapacity:0];
    instance.numberOfComponents = 1;
    return instance;
}

- (void) showPickerOver:(UIViewController *)parent{

    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    
    __block CGRect frame = self.view.frame;
    frame.origin.y = CGRectGetMaxY(window.bounds);
    self.view.frame = frame;
    
    self.background = [[UIView alloc] initWithFrame:window.bounds];
    [self.background setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.0]];
    [window addSubview:self.background];
    [window addSubview:self.view];
    [parent addChildViewController:self];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.background.backgroundColor = [self.background.backgroundColor colorWithAlphaComponent:0.5];
        frame = self.view.frame;
        frame.origin.y -= CGRectGetHeight(frame);
        self.view.frame = frame;
        
    }];
    
    [self.pickerView reloadAllComponents];
    
}


- (void) setPickerType:(PGPickerSelectorType)pickerType{
    _pickerType = pickerType;
    
    CGRect frame = self.view.frame;
    
    if (pickerType == PGPickerSelectorTypeDate) {
        [self.pickerView removeFromSuperview];
        [self.view addSubview:self.datePickerView];
        
        
        frame.size.height = CGRectGetHeight(toolBar_.frame) + CGRectGetHeight(self.datePickerView.frame);
        self.view.frame = frame;
        
        frame = self.datePickerView.frame;
        frame.origin.y = CGRectGetMaxY(toolBar_.frame);
        self.datePickerView.frame = frame;
 
    }else{
        [self.datePickerView removeFromSuperview];
        [self.view addSubview:self.pickerView];
        
        frame = self.pickerView.frame;
        frame.origin.y = CGRectGetMaxY(toolBar_.frame);
        self.pickerView.frame = frame;
        
    }
}

- (void) setOnlyDayPicker:(BOOL)onlyDaySelector{
    _onlyDayPicker = onlyDaySelector;
    if (onlyDaySelector) {
        self.datePickerView.datePickerMode = UIDatePickerModeDate;
    }else{
        self.datePickerView.datePickerMode = UIDatePickerModeDateAndTime;
    }
}


- (IBAction)setAction:(id)sender {
    if (self.pickerType == PGPickerSelectorTypeDate) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(PGPickerSelector:dateSelected:)]) {
            [self.delegate PGPickerSelector:self dateSelected:self.datePickerView.date];
        }
            [self dismissPicker];
        return;
    }
    
    if (self.delegate) {
        NSMutableString *str = [NSMutableString stringWithString:@""];
        for (int i = 0; i < self.numberOfComponents; i++) {
            if (self.numberOfComponents == 1) {
                [str appendString:self.pickerData[[self.pickerView selectedRowInComponent:0]]];
            }else{
                NSMutableArray *componentData = self.pickerData[i];
                [str appendString:componentData[[self.pickerView selectedRowInComponent:i]]];
                if (i<self.numberOfComponents-1) {
                    [str appendString:@" "];
                }
            }
        }
        
        if ([self.delegate respondsToSelector:@selector(PGPickerSelector:selectedValue:index:)]) {
            [self.delegate PGPickerSelector:self selectedValue:str index:[self.pickerView selectedRowInComponent:0]];
        }

    }
    
    [self dismissPicker];
}


- (IBAction)cancelAction:(id)sender {
    [self dismissPicker];
}

- (void) dismissPicker{
    [UIView animateWithDuration:0.3 animations:^{
        self.background.backgroundColor = [self.background.backgroundColor colorWithAlphaComponent:0];
        CGRect frame = self.view.frame;
        frame.origin.y += CGRectGetHeight(frame);
        self.view.frame = frame;
        
    } completion:^(BOOL finished) {
        [self.background removeFromSuperview];
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
    
}


#pragma mark - picker delegate and datasource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return self.numberOfComponents;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (self.numberOfComponents > 1) {
        NSMutableArray *comp = self.pickerData[component];
        return comp.count;
    }
    return self.pickerData.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if (self.numberOfComponents > 1) {
        NSMutableArray *comp = self.pickerData[component];
        return comp[row];
    }
    return self.pickerData[row];
}

@end

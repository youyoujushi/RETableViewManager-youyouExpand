//
// RETableViewTextCell.m
// RETableViewManager
//
// Copyright (c) 2013 Roman Efimov (https://github.com/romaonthego)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "RETableViewTextCell.h"
#import "RETableViewManager.h"

@interface RETableViewTextCell ()

@property (assign, readwrite, nonatomic) BOOL enabled;

@end

@implementation RETableViewTextCell

@synthesize item = _item;

+ (BOOL)canFocusWithItem:(RETableViewItem *)item
{
    return YES;
}

#pragma mark -
#pragma mark Lifecycle

- (void)dealloc {
    if (_item != nil) {
        [_item removeObserver:self forKeyPath:@"enabled"];
    }
}

- (void)cellDidLoad
{
    [super cellDidLoad];
    self.textLabel.backgroundColor = [UIColor clearColor];
    
    self.textField = [[UITextField alloc] initWithFrame:CGRectNull];
    self.textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.textField.inputAccessoryView = self.actionBar;
    self.textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.textField.delegate = self;
    [self.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.contentView addSubview:self.textField];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (selected) {
        [self.textField becomeFirstResponder];
    }
}

- (void)cellWillAppear
{
    [super cellWillAppear];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.textLabel.text = self.item.title.length == 0 ? @" " : self.item.title;
    //if(_item.titleTextColor)
    //    self.textLabel.textColor    = _item.titleTextColor;
    
    self.textField.text = self.item.value;
    self.textField.placeholder = self.item.placeholder;
    self.textField.font = [UIFont systemFontOfSize:17];
    //if(_item.detailTextColor)
    //    self.textField.textColor    = _item.detailTextColor;
    self.textField.autocapitalizationType = self.item.autocapitalizationType;
    self.textField.autocorrectionType = self.item.autocorrectionType;
    self.textField.spellCheckingType = self.item.spellCheckingType;
    self.textField.keyboardType = self.item.keyboardType;
    self.textField.keyboardAppearance = self.item.keyboardAppearance;
    self.textField.returnKeyType = self.item.returnKeyType;
    self.textField.enablesReturnKeyAutomatically = self.item.enablesReturnKeyAutomatically;
    self.textField.secureTextEntry = self.item.secureTextEntry;
    self.textField.clearButtonMode = self.item.clearButtonMode;
    self.textField.clearsOnBeginEditing = self.item.clearsOnBeginEditing;
    self.actionBar.barStyle = self.item.keyboardAppearance == UIKeyboardAppearanceAlert ? UIBarStyleBlack : UIBarStyleDefault;
    
    self.enabled = self.item.enabled;
    
    if(_item.enabled){
        self.textLabel.textColor        = _item.titleTextColor ? _item.titleTextColor : [UIColor blackColor];
        self.textField.textColor        = _item.detailTextColor ? _item.detailTextColor : [UIColor blackColor];
    }else{
        if(_item.titleDisableTextColor)
            self.textLabel.textColor    = _item.titleDisableTextColor;
        else
            self.textLabel.textColor    = [UIColor lightGrayColor];
        
        self.textField.textColor    = _item.detailDisableTextColor ? _item.detailDisableTextColor : [UIColor blackColor];
    }
    
    
}

- (UIResponder *)responder
{
    return self.textField;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self layoutDetailView:self.textField minimumWidth:0];
    
    if ([self.tableViewManager.delegate respondsToSelector:@selector(tableView:willLayoutCellSubviews:forRowAtIndexPath:)])
        [self.tableViewManager.delegate tableView:self.tableViewManager.tableView willLayoutCellSubviews:self forRowAtIndexPath:[self.tableViewManager.tableView indexPathForCell:self]];
    
    
}

#pragma mark -
#pragma mark Handle state

- (void)setItem:(RETextItem *)item
{
    if (_item != nil) {
        [_item removeObserver:self forKeyPath:@"enabled"];
    }
    
    _item = item;
    
    [_item addObserver:self forKeyPath:@"enabled" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    
    self.userInteractionEnabled = _enabled;
    
    self.textLabel.enabled = _enabled;
    self.textField.enabled = _enabled;
    
    //change the text color when enable or disable the cell
    /*if(_enabled){
        if(_item.titleTextColor)
            self.textLabel.textColor        = _item.titleTextColor;
        if(_item.detailTextColor)
            self.textField.textColor        = _item.detailTextColor;
    }else{
        if(!_item.titleTextColor)
            _item.titleTextColor    = self.textLabel.textColor;
        if(!_item.detailTextColor)
            _item.detailTextColor   = self.textField.textColor;
        self.textLabel.textColor    = [UIColor lightGrayColor];
        self.textField.textColor    = [UIColor lightGrayColor];
    }*/
        
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([object isKindOfClass:[REBoolItem class]] && [keyPath isEqualToString:@"enabled"]) {
        BOOL newValue = [[change objectForKey: NSKeyValueChangeNewKey] boolValue];
        
        self.enabled = newValue;
    }
}

#pragma mark -
#pragma mark Text field events

- (void)textFieldDidChange:(UITextField *)textField
{
    self.item.value = textField.text;
    if (self.item.onChange)
        self.item.onChange(self.item);
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSIndexPath *indexPath = [self indexPathForNextResponder];
    if (indexPath) {
        textField.returnKeyType = UIReturnKeyNext;
    } else {
        textField.returnKeyType = self.item.returnKeyType;
    }
    [self updateActionBarNavigationControl];
    [self.parentTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.rowIndex inSection:self.sectionIndex] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    if (self.item.onBeginEditing)
        self.item.onBeginEditing(self.item);
    return YES;
}

//add by youyoujushi 2015/09/28
- (void) textFieldDidBeginEditing:(UITextField *)textField{
    //[self scrollCellIfNeed];
}

-(void)scrollCellIfNeed{
    UITableView *table      = self.tableViewManager.tableView;
    
    CGRect visibleRect      = table.frame;
    visibleRect.size.height -= self.tableViewManager.keyboardSize.height;
    visibleRect.origin.y    = table.contentOffset.y;
    
    
    if(self.frame.origin.y >= visibleRect.origin.y
       && self.frame.origin.y + self.frame.size.height <=
       visibleRect.origin.y + visibleRect.size.height){
        return;//no need scroll
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        [table setContentOffset:CGPointMake(0, self.frame.origin.y - 40)];
    }];
    
}
//end add

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (self.item.onEndEditing)
        self.item.onEndEditing(self.item);
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (self.item.onReturn)
        self.item.onReturn(self.item);
    if (self.item.onEndEditing)
        self.item.onEndEditing(self.item);
    NSIndexPath *indexPath = [self indexPathForNextResponder];
    if (!indexPath) {
        [self endEditing:YES];
        return YES;
    }
    RETableViewCell *cell = (RETableViewCell *)[self.parentTableView cellForRowAtIndexPath:indexPath];
    [cell.responder becomeFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL shouldChange = YES;
    
    if (self.item.charactersLimit) {
        NSUInteger newLength = textField.text.length + string.length - range.length;
        shouldChange = newLength <= self.item.charactersLimit;
    }
    
    if (self.item.onChangeCharacterInRange && shouldChange)
        shouldChange = self.item.onChangeCharacterInRange(self.item, range, string);
    
    return shouldChange;
}


@end

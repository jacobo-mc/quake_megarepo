#ifndef __qwaq_ui_tableview_h
#define __qwaq_ui_tableview_h

#include "ruamoko/qwaq/ui/view.h"

@class DrawBuffer;
@class TableView;
@class TableViewColumn;
@class Array;
@class ListenerGroup;

@protocol TableViewDataSource
-(ListenerGroup *)onRowCountChanged;
-(int)numberOfRows:(TableView *)tableview;
-(View *)tableView:(TableView *)tableView
		 forColumn:(TableViewColumn *)column
		       row:(int)row;
-retain;
-release;
@end

@interface TableViewColumn : Object
{
	string      name;
	int         width;
	int         growMode;	// Y flags ignored
}
+(TableViewColumn *)named:(string)name;
+(TableViewColumn *)named:(string)name width:(int)width;

-setGrowMode: (int) mode;
-(int)growMode;

-(string)name;
-(int)width;
@end

@interface TableView : View
{
	Array      *columns;
	DrawBuffer *buffer;
	int         columns_dirty;
	id<TableViewDataSource> dataSource;
	Point       base;
}
+(TableView *)withRect:(Rect)rect;
-addColumn:(TableViewColumn *)column;
-setDataSource:(id<TableViewDataSource>)dataSource;
@end

#endif//__qwaq_ui_tableview_h

/*
 *  Constants.h
 *  FlashNotes
 * 
 */

#import <Foundation/Foundation.h>

#define kUpdateTableViewsUsingDeckData						@"UpdateTableViewsUsingDeckData"
#define kUpdateTableViewsUsingFavoriteData					@"UpdateTableViewsUsingFavoriteData"
#define kShowModal											@"ShowModal"
#define kHideModal											@"HideModal"

//#define ENABLE_APPLICATION_DEBUGGING						1
//#define ENABLE_APPLICATION_DEBUGGING_DATA					1
//#define ENABLE_DATABASE_LOGGING								1
//#define ENABLE_DATABASE_DEBUGGING							0
#define APPLICATION_DEBUG_VERBOSE							0
#define APPLICATION_DEBUG_GENERAL							1

#define TABLE_VIEW_CELL_FONT_SIZE_LARGE_LARGE				20.0f
#define TABLE_VIEW_CELL_FONT_SIZE_LARGE						18.0f
#define TABLE_VIEW_CELL_FONT_SIZE_LARGE_SMALL				16.0f

#define TABLE_VIEW_CELL_FONT_SIZE_NORMAL_LARGE				14.0f
#define TABLE_VIEW_CELL_FONT_SIZE_NORMAL					12.0f
#define TABLE_VIEW_CELL_FONT_SIZE_NORMAL_SMALL				10.0f

#define TABLE_VIEW_CELL_FONT_SIZE_SMALL_LARGE				8.0f
#define TABLE_VIEW_CELL_FONT_SIZE_SMALL						6.0f
#define TABLE_VIEW_CELL_FONT_SIZE_SMALL_SMALL				5.0f

#define TABLE_VIEW_CELL_CONTENT_WIDTH						320.0f
#define TABLE_VIEW_CELL_CONTENT_MARGIN						10.0f



typedef enum
{
	kSaveDeckSelection = 0,
	kDeleteDeckSelection,
	kDeleteCanNotDeckSelection
} SaveDeleteDeckSelectionEnum;
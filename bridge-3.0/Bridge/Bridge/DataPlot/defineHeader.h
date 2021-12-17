//
//  defineHeader.h
//  CPK_Test
//
//  Created by RyanGao on 2020/6/27.
//  Copyright © 2020 RyanGao. All rights reserved.
//

#ifndef defineHeader_h
#define defineHeader_h



#define  cpk_zmq_addr                @"tcp://127.0.0.1:3100"
#define  correlation_zmq_addr        @"tcp://127.0.0.1:3110"
#define  calculate_zmq_addr          @"tcp://127.0.0.1:3120"
#define  excel_report_zmq_addr       @"tcp://127.0.0.1:3130"
#define  keynote_report_zmq_addr     @"tcp://127.0.0.1:3140"
#define  retest_rate_zmq_addr        @"tcp://127.0.0.1:3150"
#define  copy_image_zmq_addr         @"tcp://127.0.0.1:3160"
#define  scatter_zmq_addr            @"tcp://127.0.0.1:3170"
#define  hash_zmq_addr               @"tcp://127.0.0.1:3180"
#define  report_tags_zmq_addr        @"tcp://127.0.0.1:3190"
#define  retest_plot_zmq_addr        @"tcp://127.0.0.1:3191"

#define  box_zmq_addr                @"tcp://127.0.0.1:3200"
#define  limit_merge_zmq_addr        @"tcp://127.0.0.1:3192"

#define Off                    @"Off"
#define Version                @"Version"
#define Diags_Version          @"Diags Version"
#define Station_ID             @"Station ID"
#define Special_Build_Name     @"Special Build Name"
#define Special_Build_Descrip  @"Special Build Description"
#define Product                @"Product"
#define Channel_ID             @"Channel ID"
#define OS_VERSION             @"OS_VERSION"


#define kRetestSeg             @"key_retest_first_all_last"    //key  retest
#define vRetestFirst           @"retest_first"                 //value first
#define vRetestAll             @"retest_all"                   //value all
#define vRetestLast            @"retest_last"                   //value last

#define kRemoveFailSeg         @"key_remove_fail_yes_no"         // key remove fail
#define vRemoveFailYes         @"remove_fail_yes"               // value remove fail yes
#define vRemoveFailNo          @"remove_fail_no"               // value remove fail yes



#define k_dic_RetestFirst_RemoveFailYes           @"retest_first&remove_fail_yes"       //%@&%@
#define k_dic_RetestAll_RemoveFailYes             @"retest_all&remove_fail_yes"
#define k_dic_RetestLast_RemoveFailYes            @"retest_last&remove_fail_yes"

#define k_dic_RetestFirst_RemoveFailNo           @"retest_first&remove_fail_no"       //%@&%@
#define k_dic_RetestAll_RemoveFailNo             @"retest_all&remove_fail_no"
#define k_dic_RetestLast_RemoveFailNo            @"retest_last&remove_fail_no"

#define k_dic_Diags_Version          @"Diags Version"
#define k_dic_OS_Version             @"OS_VERSION"
#define k_dic_Version                @"Version"
#define k_dic_Station_ID             @"Station ID"
#define k_dic_Special_Build_Name     @"Special Build Name"
#define k_dic_Special_Build_Desc     @"Special Build Description"
#define k_dic_Channel_ID             @"Channel ID"
#define k_dic_Product                @"Product"
#define k_dic_Channel_ID_Index       @"Item_Channel_ID_Index"
//#define k_dic_Station_Channel_ID     @"Station ID & Channel ID"
//#define k_dic_Station_Channel_ID_Index     @"Station_ID_And_Item_Channel_ID_Index"
#define K_dic_ApplyBoxCheck                @"Apply_Box_Check_or_not"
#define K_dic_keynoteBoxCheck              @"Apply_Keynote_Box_Check_or_not"

#define K_dic_Load_Csv_Finished            @"Is_Load_Csv_Finished?"

#define Start_Data                             @"Start_Data"
#define End_Data                               @"End_Data"

#define kBins                                  @"key_bins"                     // key for bins

#define kSelectColorByTableRowsLeft            @"key_select_Table_Rows_Left"             //
#define kSelectColorByTableRowsRight           @"key_select_Table_Rows_Right"             //

#define FCT_RAW_DATA             "FCT_RAW_DATA"
#define FCT_SCRIPT_VERSION       "FCT_SCRIPT_VERSION"
#define FCT_ITEMS_NAME           "FCT_ITEMS_NAME"

#define Load_Csv_Path                          @"Load_all_Csv_data_path"
#define Load_Script_Path                       @"Load_Test_Script_path"
#define Load_Local_Csv_Path                    @"Load_Local_Csv_data_path"
#define k_All_Item_Name                        @"k_All_Item_Name"
#define kLoadGroupPanel                        @"k_Load_group_select_panel"
#define kSetLocalCsvMode                       @"set_load_local_data?"
#define kSetInsightCsvMode                     @"set_load_Insight_data?"

#define kNotificationClickPlotTable            @"Notification_Click_Plot_TableView_Items_left"
#define kNotificationClickPlotTable2           @"Notification_Click_Plot_TableView_Items_right"
#define kNotificationClickPlotTable_selectXY   @"Notification_Click_Plot_select_XY"
#define kNotificationInitColorTable            @"Notification_Init_Color_Table_Control"
#define kNotificationSetRangeLslUsl            @"Notification_set_range_lsl_usl"
#define krangelsl                              @"k_range_lsl"
#define krangeusl                              @"k_range_usl"
#define kInputRangeFlag                        @"k_Input_Range_Flag"


//#define kInsightDataPath                       @""
#define kNotificationSetCpkImage               @"Notification_Set_Cpk_Image"
#define kNotificationSetCpkNew                 @"Notification_Set_Cpk_New_Number"
#define kNotificationSetCorrelationImage       @"Notification_Set_Correlation_Image"
#define kNotificationSetScatterImage           @"Notification_Set_Scatter_Image"
#define kNotificationSetRetestImage            @"Notification_Set_Retest_Image"

#define kNotificationSetColorByLeft            @"kNotification_Setting_Color_By_Left"
#define kNotificationSetColorByRight           @"kNotification_Setting_Color_By_Right"
#define select_Color_Box_left                  @"select_Color_Box_Left_Index"
#define select_Color_Box_Right                 @"select_Color_Box_Right_Index"

#define kNotificationSelectX                   @"kNotification_Select_X_Button"
#define kNotificationSelectY                   @"kNotification_Select_Y_Button"
#define kNotificationSaveUIdata                @"kNotification_Save_UI_Data"
#define kNotificationSetParameters             @"kNotification_Set_Parameters"
#define kNotificationToLoadCsv                 @"kNotification_Load_Csv"
#define kNotificationToLocalLoadCsv            @"kNotification_Local_To_Load_Csv"
#define kNotificationClickOneItem              @"kNotification_Click_OneItem"
#define btn_select_x                           @"click_select_x_button"
#define btn_select_y                           @"click_select_y_button"

#define kNotificationGenerateExcel             @"kNotification_Generate_Excel_Finished"
#define kNotificationAddExcelHash              @"kNotification_Add_Excel_Hash_Finished"
#define kNotificationGenerateKeynote           @"kNotification_Generate_Keynote_Finished"

#define kNotificationRetestRate                @"kNotification_Generate_YieldRetest_Rate"
#define kNotificationShowData                  @"kNotification_Show_Data"
#define kNotificationReloadSkipSettingData     @"kNotification_Reload_Skip_Setting_Data"
#define kNotificationReloadReportTags          @"kNotification_Reload_Report_Tags"

#define kSerial_number                         @"k_Serial_number"
#define kData_Value                            @"k_Data_Value"

#define ktbHeaderX                             @"k_tableView_header_x"
#define ktbHeaderY                             @"k_tableView_header_y"
#define ktbHeaderID                            @"k_tableView_header_id"
#define kNotificationMouseEnter                @"k_Notification_Mouse_Enter"
#define kNotificationMouseExit                 @"k_Notification_Mouse_Exit"

#define imagePath                              @"image_path"
#define imageId                                @"image_id"
#define cpkNewNumber                           @"cpk_new_number"
#define limit_update_path                      @"for_limit_update_path"
#define paramPath                              @"parameter_Path"
#define applyBoxCheck                          @"is_Apply_Box_Check?"

#define selectXY                               @"selectX_And_Y"
#define kChooseItemIndex                       @"k_Choose_Item_Index"
#define kChooseItemName                        @"k_Choose_Item_Name"

#define NUMBERS                                @"0123456789.-"

#define cpk_Lowthl                             @"to_Define_cpk_LOW"
#define cpk_Highthl                            @"to_Define_cpk_HIGH"
#define kzoom_type                             @"to_Define_Zoom_Type_Limit"

// ----custom csv column
#define KrawDataTmp                             @"K_raw_Data_Tmp"
#define KcustomCsvStartRow                      @"k_custom_csv_Start_Row"
#define KcustomCsvUpperLimitRow                 @"k_custom_csv_UpperLimit_Row"
#define KcustomCsvLowerLimitRow                 @"k_custom_csv_LowerLimit_Row"
#define KcustomCsvUnitRow                       @"k_custom_csv_Unit_Row"
#define KcustomCsvDataStartRow                  @"k_custom_csv_Datatart_Row"

#define KcustomCsvPassFailCol                   @"k_custom_csv_Pass_Fail_Col"
#define KcustomCsvSerialNumberCol               @"k_custom_csv_SerialNumber_Col"
#define KcustomCsvStartTimeCol                  @"k_custom_csv_StartTime_Col"
#define KcustomCsvProductCol                    @"k_custom_csv_Product_Col"
#define KcustomCsvStationIdCol                  @"k_custom_csv_StationId_Col"
#define KcustomCsvStartItemCol                  @"k_custom_csv_StartItem_Col"
#define KcustomCsvVersionCol                    @"k_custom_csv_Version_Col"
#define KcustomCsvListOfFailCol                 @"k_custom_csv_ListOfFail_Col"
#define KcustomCsvSlotIdCol                     @"k_custom_csv_SlotId_Col"

#define KcustomCsvPassFailWord                  @"k_custom_csv_Pass_Fail_Word"
#define KcustomCsvSerialNumberWord              @"k_custom_csv_SerialNumber_Word"
#define KcustomCsvStartTimeWord                 @"k_custom_csv_StartTime_Word"
#define KcustomCsvProductWord                   @"k_custom_csv_Product_Word"
#define KcustomCsvStationIdWord                 @"k_custom_csv_StationId_Word"
#define KcustomCsvStartItemWord                 @"k_custom_csv_StartItem_Word"
#define KcustomCsvVersionWord                   @"k_custom_csv_Version_Word"
#define KcustomCsvListOfFailWord                @"k_custom_csv_ListOfFail_Word"
#define KcustomCsvSlotIdWord                    @"k_custom_csv_StartItem_Word"

#define kcustomToInsightCsv                        @"/tmp/CPK_Log/temp/.custom2insight.csv"

//--------csv col define------
//#define Start_Data_Row                 7
//#define Start_Data_Col                 11
//#define Pass_Fail_Status               7
//#define Product_Col                    1
//#define SerialNumber                   2
//#define SpecialBuildName_Col           3
//#define Special_Build_Descrip_Col      4
//#define StationID_Col                  6
//#define Start_Calc_Data_Col            12
//#define StartTime                      8
//#define Version_Col                    10

#define BC_Col                         11
#define p_val_Col                      12
#define a_q_Cal                        13
#define a_irr_Cal                      14
#define CV3_Cal                        15


// excel update limit file
#define updatelimit_newLower               18  //17
#define updatelimit_newUpper               20  //19
#define updatelimit_reviewer_name          25  //24
#define updatelimit_reviewer_date          26  //25
#define updatelimit_user_comment           27  //26

// select column
#define col_select_index                    0
#define col_select_cpk_orig                 5
#define col_select_reviewer_name            10+1
#define col_select_bm                       12+1
#define col_edit_new_lsl                    6
#define col_edit_new_usl                    7
#define col_edit_comment                    9+1
#define col_edit_reviewer_name              10+1
#define col_edit_review_date                11+1
#define col_edit_cpk_new                    9

// NSTableView identifier
#define identifier_index                    @"index"
#define identifier_item                     @"item"
#define identifier_low                      @"low"
#define identifier_upper                    @"upper"
#define identifier_unit                     @"unit"
#define identifier_lsl                      @"lsl"
#define identifier_usl                      @"usl"
#define identifier_apply                    @"apply"
#define identifier_keynote                  @"keynote"
#define identifier_description              @"description"
#define identifier_cpknew                   @"cpknew"
#define identifier_command                  @"command"
#define identifier_reviewer                 @"reviewer"
#define identifier_date                     @"date"
#define identifier_bmc                      @"bmc"
#define identifier_comment                  @"comment"
//#define identifier_3cv                      @"3cv"
#define identifier_cpk_orig                 @"cpk_orig"




//--------UI Table View Display------
#define tb_index               0
#define tb_item                1
#define tb_display_name        2
#define tb_PDCA_priority       3
#define tb_measurement_unit    6

#define tb_lower      5
#define tb_upper      4
#define tb_lsl        7
#define tb_usl        8
#define tb_apply      9
#define tb_description      10
//#define tb_bc         11
#define tb_command      11
//#define tb_p_val      12
#define tb_reviewer     12
//#define tb_a_q        13
#define tb_date         13

#define tb_comment      14
#define tb_3cv        15
#define tb_cpk_orig   16
#define tb_bmc        17
#define tb_zoom_type  18
#define tb_bins       19
#define tb_keynote         23
#define tb_correlation_xy  26
#define tb_range_lsl       27
#define tb_range_usl       28
#define tb_cpk_new         29
#define tb_cpk_log_path    30
#define tb_color_by_left   31
#define tb_color_by_right  32
#define button_select_x    33
#define button_select_y    34

#define create_empty_line  30
#define create_empty_line_local  33  //local 数据比insight 数据少3行,需要多创建3行
#define tb_script_flag   35
#define tb_data       36
#define tb_data_start       37




// ********************generate Excel ********
#define kexportAllItems            @"K_exp_All_Items"
#define kexportPassItems           @"K_exp_pass_Items"
#define kcpkLowThd                 @"K_cpk_Low_Threshold"
#define kcpkHighThd                @"K_cpk_High_Threshold"
#define kpopulateDistri            @"K_populate_distribution"
#define kp_val_status              @"K_P_Val_check_status"
#define kuserName                  @"k_user_name"
#define kprojectName               @"k_project_name"
#define ktargetBuild               @"k_target_build"
#define kpush2GitHub               @"k_push_to_Git_Hub"
#define kgitWebAddr                @"k_Git_Hub_web_address"
#define kgitComment                @"k_Git_Hub_Comment"
#define konlyLimitUpdated          @"K_only_Limit_Updated"

// ********************generate keynote ********
#define kcpkKeynoteLowThd                 @"K_Low_Keynote_CPK_Threshold"
#define kcpkKeynoteHighThd                @"K_cpk_High_Keynote_CPK_Threshold"
#define khasBiggerThanLowThd              @"K_Keynote_khasBiggerThanLowThd"


#define kkeynoteSkipSummarySlid                 @"k_keynote_Skip_Summary_Slid"

#define kkeynotePlotType                 @"K_Keynote_Plot_Type"

#define kkeynotePrjName                   @"K_Keynote_Project_Name"
#define kkeynoteBuild                     @"K_Keynote_Target_Build"
#define kkeynotePlotCount                 @"K_Keynote_Plot_Count"
#define kchooseUIK                        @"K_value_for_UI_choose"

#define KitemAdvancedYes                  @"item_Advanced_Yes"
#define KitemAdvancedNo                   @"item_Advanced_No"
#define Kitem1aYes                        @"item_1a_Yes"
#define Kitem1aNo                         @"item_1a_No"
#define Kitem1bYes                        @"item_1b_Yes"
#define Kitem1bNo                         @"item_1b_No"

#define KskipOneLimitYes                  @"skip_One_Limit_Yes"
#define KskipOneLimitNo                   @"skip_One_Limit_No"
#define KskipHTHLDYes                     @"skip_HTHLD_Yes"
#define KskipHTHLDNo                      @"skip_HTHLD_No"

#define Kkeynote_skip_setting_Cancel      @"K_keynote_skip_setting_Cancel"


#define KdataItemNamePath                 @"/tmp/CPK_Log/temp/.dataItemName.csv"
#define KItemNameInsight                  @"Item_name_insight"
#define KItemNameScript                   @"Item_name_Script"
//#define KItemNamePathDataTmp              @"/tmp/CPK_Log/temp/.ItemNameTmp.csv"
//#define KItemNamePathDataScriptTmp        @"/tmp/CPK_Log/temp/.ItemNameTmpScript.csv"

#define KGreenColorIndex                  @"Green_Color_Index"
#define KRedColorIndex                    @"Red_Color_Index"
#define KreportTagsExcelPath              @"Report_Tags_Excel_Path"
#define BUFSIZE    1024*16

//  some resid default setting
#define KSetPDF                           @"Set_CPK_CheckBox_PDF"
#define KSetCDF                           @"Set_CPK_CheckBox_CDF"


#define KYieldRatePath                    @"/tmp/CPK_Log/temp/yield_rate_param.csv"
#define KRetestPath                       @"/tmp/CPK_Log/retest/retest_item_overall.csv"
#define KFailPath                         @"/tmp/CPK_Log/retest/fail_item_overall.csv"
#define KCpkRangePath                     @"/tmp/CPK_Log/retest/cpk_min_max.csv"
#define KRetestByFixturePath              @"/tmp/CPK_Log/retest/retest_breakdown_fixture.csv"

#define KbuildSummary                    @"/tmp/CPK_Log/retest/.buildsummary.txt"



#define pie_retest_csv                    @"/tmp/CPK_Log/retest/.pie_retest.csv"
#define retest_csv_csv                    @"/tmp/CPK_Log/retest/.retest_csv.csv"
#define retest_vs_station_id_csv          @"/tmp/CPK_Log/retest/.retest_vs_station_id.csv"
#define retest_vs_version_csv             @"/tmp/CPK_Log/retest/.retest_vs_version.csv"
#define summary_retest_csv                @"/tmp/CPK_Log/retest/.summary_retest.csv"
#define cpk_min_max_csv                   @"/tmp/CPK_Log/retest/cpk_min_max.csv"
#define daily_retest_summary_png          @"/tmp/CPK_Log/retest/daily_retest_summary.png"
#define fail_item_overall_csv             @"/tmp/CPK_Log/retest/fail_item_overall.csv"
#define fail_pareto_png                   @"/tmp/CPK_Log/retest/fail_pareto.png"
#define retest_breakdown_fixture_csv      @"/tmp/CPK_Log/retest/retest_breakdown_fixture.csv"
#define retest_item_overall_csv           @"/tmp/CPK_Log/retest/retest_item_overall.csv"
#define retest_pareto_png                 @"/tmp/CPK_Log/retest/retest_pareto.png"
#define retest_pie_png                    @"/tmp/CPK_Log/retest/retest_pie.png"
#define retest_vs_station_id_png          @"/tmp/CPK_Log/retest/retest_vs_station_id.png"
#define retest_vs_version_png             @"/tmp/CPK_Log/retest/retest_vs_version.png"
#define header_info_csv_csv               @"/tmp/CPK_Log/retest/.header_info_csv.csv"
#define fail_csv_csv                      @"/tmp/CPK_Log/retest/.fail_csv.csv"
#define total_count_by_version_csv          @"/tmp/CPK_Log/retest/..total_count_by_version.csv"
#define total_count_by_station_slot_id_csv  @"/tmp/CPK_Log/retest/..total_count_by_station_slot_id.csv"
#define total_count_by_date_product_csv     @"/tmp/CPK_Log/retest/..total_count_by_date_product.csv"

#define yield_rate_param_tmp_csv                @"/tmp/CPK_Log/retest/.yield_rate_param_tmp.csv"
#define cpk_range_csv                           @"/tmp/CPK_Log/retest/.cpk_range.csv"
#define daily_retest_summary_x                  @"/tmp/CPK_Log/retest/daily_retest_summary"
#define retest_vs_station_id_x                  @"/tmp/CPK_Log/retest/retest_vs_station_id"
#define retest_vs_version_x                     @"/tmp/CPK_Log/retest/retest_vs_version"

#define daily_all_retest_summary_x                  @"/tmp/CPK_Log/retest/daily_all_retest_summary"
#define daily_all_retest_summary_png                @"/tmp/CPK_Log/retest/daily_all_retest_summary.png"



//  help info

#define helpInfo_index                          @"Hide/Show test script items if applicable. Green =Match between data and script; Gray = Exists in Script, but not in data. Red = Exists in data but not in Script"

#define helpInfo_low                            @"Original Lower Limit from Data file"
#define helpInfo_upper                          @"Original upper Limit from Data file"
#define helpInfo_cpk_orig                       @"Cpk of ALL PASS data based on original LSL/USL. Click to filter the test items by this item. Not affected by any filter selection. Cpk< Cpk-LTHL = RED, Cpk > CPk-HTHL = Yellow ; Other = GREEN"
#define helpInfo_lsl                            @"New LSL as entered by user"
#define helpInfo_usl                            @"New USL as entered by user"
#define helpInfo_apply                          @"Click to apply new LSL/USL"
#define helpInfo_cpk_new                        @"Cpk of ALL PASS data based on NEW Entered LSL/USL. Not affected by any filter selection. Cpk< Cpk-LTHL = RED, Cpk > CPk-HTHL = Yellow ; Other = GREEN"
#define helpInfo_comment                        @"Add reviewer comment if needed. Will be exported to next Excel report. Pre-populated with previous reviewer's comment if previous limit review excel was loaded."
#define helpInfo_reviewer                       @"Previous reviewer's name. Shown only if previous limit review Excel was loaded . Can't type in here. Auto exported to next Excel report with reviewer name picked from \"Report Excel--> \"User Name\" field"
#define helpInfo_date                           @"Date of Review based on PST. Shown only if previous limit review Excel was loaded . Auto exported to next Excel report"
#define helpInfo_bmc                            @"Distribution Bimodality judgement based on Modified Dip test using original PASS data only. Click to filter by YES/NO/DEFAULT. Not Judged for  items with Cpk-Orig >CPk-HTHL"
#define helpInfo_keynote                        @"Click to make sure this item is always exported to Keynote report"
#define helpInfo_command                        @"\"Command\" column from test script CSV , if loaded"
#define helpInfo_description                    @"\"Description\" column from test script CSV , if loaded"
#define helpInfo_Report_tags                    @"Extract tags from Data file following standard naming rules. If script loaded, extract from Both Data and Script showing proper color codes (RED, Gray, Green)"

#define kReport_tags                            @"k_Report_tags"


//**************load msg*************/
#define kNotificationIndicatorMsg                    @"kNotification_Load_Msg_Log"
#define kStartupMsg                                  @"k_Startup_Msg"
#define kStartupLevel                                @"k_Startup_Level"
#define kStartupPercentage                           @"k_Startup_Percentage"

typedef enum {
    MSG_LEVEL_NORMAL,
    MSG_LEVEL_WARNNING,
    MSG_LEVEL_ERROR,
}MSG_LEVEL;

#define kNotificationHidenAllWindows                  @"kNotification_Hiden_All_Windows"

#define kNotificationShowStartUp                    @"kNotification_Show_Start_Up"
#define kNotificationCloseStartUp                   @"kNotification_Close_Start_Up"

#define kNotificationInShowFilter                        @"k_Filter_Show_Filter"
#define kNotificationInHidenFilter                        @"k_Filter_Hiden_Filter"
#define kNotificationFilterMsg                        @"k_Do_Filter_Msg"
#define kNotificationFilterClearMsg                        @"k_Clear_Filter_Msg"

#define kNotificationShowDataFilterMsg                        @"k_ShowData_Do_Filter_Msg"


#define kNotificationProgressMsg                        @"k_Do_Progress_Msg"
#define kNotificationShowProgressUp                    @"kNotification_Show_Progress_Up"
#define kNotificationCloseProgressUp                    @"kNotification_Close_Progress_Up"

#define kNotificationLimitMergerShowUp      @"kNotification_Merger_Progress_Up"
#define kNotificationLimitMergerShowClose   @"kNotification_Merger_Progress_Close"


#define kNotificationLoginShowUp      @"kNotification_Login_Up"
#define kNotificationLoginShowClose   @"kNotification_Login_Close"



#endif /* defineHeader_h */

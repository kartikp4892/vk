"-------------------------------------------------------------------------------
" s:GetTemplete: Function
"-------------------------------------------------------------------------------
function! s:GetTemplete(char, ...)
  return common#mov_thru_user_mark#get_template(a:char, a:000)
endfunction

"-------------------------------------------------------------------------------
" _set_indent: Function
"-------------------------------------------------------------------------------
function! s:_set_indent(offset)
  return '=common#indent#imode_set_indent(' . a:offset . ')'
endfunction

function! python#xlrd#Book()
  let str = "Book(filename=None, file_contents=None, logfile=sys.stdout, verbosity=0, pickleable=True, use_mmap=USE_MMAP, encoding_override=None, formatting_info=False, )"
  return str
endfunction

function! python#xlrd#Cell()
  let str = "Cell(ctype, value, xf_index=None)"
  return str
endfunction

function! python#xlrd#cellname()
  let str = "cellname(rowx, colx)"
  return str
endfunction

function! python#xlrd#cellnameabs()
  let str = "cellnameabs(rowx, colx)"
  return str
endfunction

function! python#xlrd#Colinfo()
  let str = "Colinfo"
  return str
endfunction

function! python#xlrd#colname()
  let str = "colname(colx)"
  return str
endfunction

function! python#xlrd#count_records()
  let str = "count_records(filename, outfile=sys.stdout)"
  return str
endfunction

function! python#xlrd#dump()
  let str = "dump(filename, outfile=sys.stdout)"
  return str
endfunction

function! python#xlrd#empty_cell()
  let str = "empty_cell (variable)"
  return str
endfunction

function! python#xlrd#EqNeAttrs()
  let str = "EqNeAttrs"
  return str
endfunction

function! python#xlrd#error_text_from_code()
  let str = "error_text_from_code (variable)"
  return str
endfunction

function! python#xlrd#Font()
  let str = "Font"
  return str
endfunction

function! python#xlrd#Format()
  let str = "Format(format_key, ty, format_str)"
  return str
endfunction

function! python#xlrd#Name()
  let str = "Name"
  return str
endfunction

function! python#xlrd#open_workbook()
  " let str = "xlrd.open_workbook(filename=None, logfile=sys.stdout, verbosity=0, pickleable=True, use_mmap=USE_MMAP, file_contents=None, encoding_override=None, formatting_info=False, )"
  let str = "xlrd.open_workbook(filename=maa" . s:GetTemplete('1', 'name') . ")`aa"
  return str
endfunction

function! python#xlrd#Operand()
  let str = "Operand(akind=None, avalue=None, arank=0, atext='?')"
  return str
endfunction

function! python#xlrd#rangename3d()
  let str = "rangename3d(book, ref3d)"
  return str
endfunction

function! python#xlrd#rangename3drel()
  let str = "rangename3drel(book, ref3d)"
  return str
endfunction

function! python#xlrd#Ref3D()
  let str = "Ref3D(atuple)"
  return str
endfunction

function! python#xlrd#Rowinfo()
  let str = "Rowinfo"
  return str
endfunction

function! python#xlrd#Sheet()
  let str = "Sheet(book, position, name, number)"
  return str
endfunction

function! python#xlrd#XF()
  let str = "XF"
  return str
endfunction

function! python#xlrd#XFAlignment()
  let str = "XFAlignment"
  return str
endfunction

function! python#xlrd#XFBackground()
  let str = "XFBackground"
  return str
endfunction

function! python#xlrd#XFBorder()
  let str = "XFBorder"
  return str
endfunction

function! python#xlrd#XFProtection()
  let str = "XFProtection"
  return str
endfunction

function! python#xlrd#xldate_as_tuple()
  let str = "xldate_as_tuple(xldate, datemode)"
  return str
endfunction

function! python#xlrd#xldate_from_date_tuple()
  let str = "xldate_from_date_tuple((year, month, day), datemode)"
  return str
endfunction

function! python#xlrd#xldate_from_datetime_tuple()
  let str = "xldate_from_datetime_tuple(datetime_tuple, datemode)"
  return str
endfunction

function! python#xlrd#xldate_from_time_tuple()
  let str = "xldate_from_time_tuple((hour, minute, second))"
  return str
endfunction

function! python#xlrd#BaseObject()
  let str = "BaseObject"
  return str
endfunction

function! python#xlrd#dump()
  let str = "dump(f=None, header=None, footer=None, indent=0)"
  return str
endfunction

function! python#xlrd#Book()
  let str = "Book(filename=None, file_contents=None, logfile=sys.stdout, verbosity=0, pickleable=True, use_mmap=USE_MMAP, encoding_override=None, formatting_info=False, )"
  return str
endfunction

function! python#xlrd#biff_version()
  let str = "biff_version"
  return str
endfunction

function! python#xlrd#codepage()
  let str = "codepage"
  return str
endfunction

function! python#xlrd#colour_map()
  let str = "colour_map"
  return str
endfunction

function! python#xlrd#countries()
  let str = "countries"
  return str
endfunction

function! python#xlrd#datemode()
  let str = "datemode"
  return str
endfunction

function! python#xlrd#encoding()
  let str = "encoding"
  return str
endfunction

function! python#xlrd#font_list()
  let str = "font_list"
  return str
endfunction

function! python#xlrd#format_list()
  let str = "format_list"
  return str
endfunction

function! python#xlrd#format_map()
  let str = "format_map"
  return str
endfunction

function! python#xlrd#load_time_stage_1()
  let str = "load_time_stage_1"
  return str
endfunction

function! python#xlrd#load_time_stage_2()
  let str = "load_time_stage_2"
  return str
endfunction

function! python#xlrd#name_and_scope_map()
  let str = "name_and_scope_map"
  return str
endfunction

function! python#xlrd#name_map()
  let str = "name_map"
  return str
endfunction

function! python#xlrd#name_obj_list()
  let str = "name_obj_list"
  return str
endfunction

function! python#xlrd#nsheets()
  let str = "nsheets"
  return str
endfunction

function! python#xlrd#palette_record()
  let str = "palette_record"
  return str
endfunction

function! python#xlrd#sheet_by_index()
  let str = "sheet_by_index(maa)`aa"
  return str
endfunction

function! python#xlrd#sheet_by_name()
  let str = "sheet_by_name(maa)`aa"
  return str
endfunction

function! python#xlrd#sheet_names()
  let str = "sheet_names()"
  return str
endfunction

function! python#xlrd#sheets()
  let str = "sheets()"
  return str
endfunction

function! python#xlrd#style_name_map()
  let str = "style_name_map"
  return str
endfunction

function! python#xlrd#user_name()
  let str = "user_name"
  return str
endfunction

function! python#xlrd#xf_list()
  let str = "xf_list"
  return str
endfunction

function! python#xlrd#Cell()
  let str = "Cell(ctype, value, xf_index=None)"
  return str
endfunction

function! python#xlrd#Colinfo()
  let str = "Colinfo"
  return str
endfunction

function! python#xlrd#bit1_flag()
  let str = "bit1_flag"
  return str
endfunction

function! python#xlrd#collapsed()
  let str = "collapsed"
  return str
endfunction

function! python#xlrd#hidden()
  let str = "hidden"
  return str
endfunction

function! python#xlrd#outline_level()
  let str = "outline_level"
  return str
endfunction

function! python#xlrd#width()
  let str = "width"
  return str
endfunction

function! python#xlrd#xf_index()
  let str = "xf_index"
  return str
endfunction

function! python#xlrd#EqNeAttrs()
  let str = "EqNeAttrs"
  return str
endfunction

function! python#xlrd#Font()
  let str = "Font"
  return str
endfunction

function! python#xlrd#bold()
  let str = "bold"
  return str
endfunction

function! python#xlrd#character_set()
  let str = "character_set"
  return str
endfunction

function! python#xlrd#colour_index()
  let str = "colour_index"
  return str
endfunction

function! python#xlrd#escapement()
  let str = "escapement"
  return str
endfunction

function! python#xlrd#family()
  let str = "family"
  return str
endfunction

function! python#xlrd#font_index()
  let str = "font_index"
  return str
endfunction

function! python#xlrd#height()
  let str = "height"
  return str
endfunction

function! python#xlrd#italic()
  let str = "italic"
  return str
endfunction

function! python#xlrd#name()
  let str = "name"
  return str
endfunction

function! python#xlrd#outline()
  let str = "outline"
  return str
endfunction

function! python#xlrd#shadow()
  let str = "shadow"
  return str
endfunction

function! python#xlrd#struck_out()
  let str = "struck_out"
  return str
endfunction

function! python#xlrd#underline_type()
  let str = "underline_type"
  return str
endfunction

function! python#xlrd#underlined()
  let str = "underlined"
  return str
endfunction

function! python#xlrd#weight()
  let str = "weight"
  return str
endfunction

function! python#xlrd#Format()
  let str = "Format(format_key, ty, format_str)"
  return str
endfunction

function! python#xlrd#format_key()
  let str = "format_key"
  return str
endfunction

function! python#xlrd#format_str()
  let str = "format_str"
  return str
endfunction

function! python#xlrd#type()
  let str = "type"
  return str
endfunction

function! python#xlrd#Name()
  let str = "Name"
  return str
endfunction

function! python#xlrd#binary()
  let str = "binary"
  return str
endfunction

function! python#xlrd#builtin()
  let str = "builtin"
  return str
endfunction

function! python#xlrd#cell()
  let str = "cell()"
  return str
endfunction

function! python#xlrd#complex()
  let str = "complex"
  return str
endfunction

function! python#xlrd#func()
  let str = "func"
  return str
endfunction

function! python#xlrd#funcgroup()
  let str = "funcgroup"
  return str
endfunction

function! python#xlrd#hidden()
  let str = "hidden"
  return str
endfunction

function! python#xlrd#macro()
  let str = "macro"
  return str
endfunction

function! python#xlrd#name()
  let str = "name"
  return str
endfunction

function! python#xlrd#name_index()
  let str = "name_index"
  return str
endfunction

function! python#xlrd#raw_formula()
  let str = "raw_formula"
  return str
endfunction

function! python#xlrd#result()
  let str = "result"
  return str
endfunction

function! python#xlrd#scope()
  let str = "scope"
  return str
endfunction

function! python#xlrd#vbasic()
  let str = "vbasic"
  return str
endfunction

function! python#xlrd#Operand()
  let str = "Operand(akind=None, avalue=None, arank=0, atext='?')"
  return str
endfunction

function! python#xlrd#kind()
  let str = "kind"
  return str
endfunction

function! python#xlrd#text()
  let str = "text"
  return str
endfunction

function! python#xlrd#value()
  let str = "value"
  return str
endfunction

function! python#xlrd#Ref3D()
  let str = "Ref3D(atuple)"
  return str
endfunction

function! python#xlrd#Rowinfo()
  let str = "Rowinfo"
  return str
endfunction

function! python#xlrd#additional_space_above()
  let str = "additional_space_above"
  return str
endfunction

function! python#xlrd#additional_space_below()
  let str = "additional_space_below"
  return str
endfunction

function! python#xlrd#has_default_height()
  let str = "has_default_height"
  return str
endfunction

function! python#xlrd#has_default_xf_index()
  let str = "has_default_xf_index"
  return str
endfunction

function! python#xlrd#height()
  let str = "height"
  return str
endfunction

function! python#xlrd#height_mismatch()
  let str = "height_mismatch"
  return str
endfunction

function! python#xlrd#hidden()
  let str = "hidden"
  return str
endfunction

function! python#xlrd#outline_group_starts_ends()
  let str = "outline_group_starts_ends"
  return str
endfunction

function! python#xlrd#outline_level()
  let str = "outline_level"
  return str
endfunction

function! python#xlrd#xf_index()
  let str = "xf_index"
  return str
endfunction

function! python#xlrd#Sheet()
  let str = "Sheet(book, position, name, number)"
  return str
endfunction

function! python#xlrd#cell()
  let str = "cell(rowx, colx)"
  return str
endfunction

function! python#xlrd#cell_type()
  let str = "cell_type(rowx, colx)"
  return str
endfunction

function! python#xlrd#cell_value()
  let str = "cell_value(rowx, colx)"
  return str
endfunction

function! python#xlrd#cell_xf_index()
  let str = "cell_xf_index(rowx, colx)"
  return str
endfunction

function! python#xlrd#col()
  let str = "col(colx)"
  return str
endfunction

function! python#xlrd#col_label_ranges()
  let str = "col_label_ranges"
  return str
endfunction

function! python#xlrd#col_slice()
  let str = "col_slice(colx, start_rowx=0, end_rowx=None)"
  return str
endfunction

function! python#xlrd#col_types()
  let str = "col_types(colx, start_rowx=0, end_rowx=None)"
  return str
endfunction

function! python#xlrd#col_values()
  let str = "col_values(colx, start_rowx=0, end_rowx=None)"
  return str
endfunction

function! python#xlrd#colinfo_map()
  let str = "colinfo_map"
  return str
endfunction

function! python#xlrd#computed_column_width()
  let str = "computed_column_width(colx)"
  return str
endfunction

function! python#xlrd#default_additional_space_above()
  let str = "default_additional_space_above"
  return str
endfunction

function! python#xlrd#default_additional_space_below()
  let str = "default_additional_space_below"
  return str
endfunction

function! python#xlrd#default_row_height()
  let str = "default_row_height"
  return str
endfunction

function! python#xlrd#default_row_height_mismatch()
  let str = "default_row_height_mismatch"
  return str
endfunction

function! python#xlrd#default_row_hidden()
  let str = "default_row_hidden"
  return str
endfunction

function! python#xlrd#defcolwidth()
  let str = "defcolwidth"
  return str
endfunction

function! python#xlrd#gcw()
  let str = "gcw"
  return str
endfunction

function! python#xlrd#merged_cells()
  let str = "merged_cells"
  return str
endfunction

function! python#xlrd#name()
  let str = "name"
  return str
endfunction

function! python#xlrd#ncols()
  let str = "ncols"
  return str
endfunction

function! python#xlrd#nrows()
  let str = "nrows"
  return str
endfunction

function! python#xlrd#row()
  let str = "row(rowx)"
  return str
endfunction

function! python#xlrd#row_label_ranges()
  let str = "row_label_ranges"
  return str
endfunction

function! python#xlrd#row_slice()
  let str = "row_slice(rowx, start_colx=0, end_colx=None)"
  return str
endfunction

function! python#xlrd#row_types()
  let str = "row_types(rowx, start_colx=0, end_colx=None)"
  return str
endfunction

function! python#xlrd#row_values()
  let str = printf("row_values(maa%s, start_colx=0, end_colx=None)`aa", s:GetTemplete('1', '/rowx'))
  return str
endfunction

function! python#xlrd#rowinfo_map()
  let str = "rowinfo_map"
  return str
endfunction

function! python#xlrd#standardwidth()
  let str = "standardwidth"
  return str
endfunction

function! python#xlrd#visibility()
  let str = "visibility"
  return str
endfunction

function! python#xlrd#XF()
  let str = "XF"
  return str
endfunction

function! python#xlrd#_alignment_flag()
  let str = "_alignment_flag"
  return str
endfunction

function! python#xlrd#_background_flag()
  let str = "_background_flag"
  return str
endfunction

function! python#xlrd#_border_flag()
  let str = "_border_flag"
  return str
endfunction

function! python#xlrd#_font_flag()
  let str = "_font_flag"
  return str
endfunction

function! python#xlrd#_format_flag()
  let str = "_format_flag"
  return str
endfunction

function! python#xlrd#_protection_flag()
  let str = "_protection_flag"
  return str
endfunction

function! python#xlrd#alignment()
  let str = "alignment"
  return str
endfunction

function! python#xlrd#background()
  let str = "background"
  return str
endfunction

function! python#xlrd#border()
  let str = "border"
  return str
endfunction

function! python#xlrd#font_index()
  let str = "font_index"
  return str
endfunction

function! python#xlrd#format_key()
  let str = "format_key"
  return str
endfunction

function! python#xlrd#is_style()
  let str = "is_style"
  return str
endfunction

function! python#xlrd#parent_style_index()
  let str = "parent_style_index"
  return str
endfunction

function! python#xlrd#protection()
  let str = "protection"
  return str
endfunction

function! python#xlrd#xf_index()
  let str = "xf_index"
  return str
endfunction

function! python#xlrd#XFAlignment()
  let str = "XFAlignment"
  return str
endfunction

function! python#xlrd#hor_align()
  let str = "hor_align"
  return str
endfunction

function! python#xlrd#indent_level()
  let str = "indent_level"
  return str
endfunction

function! python#xlrd#rotation()
  let str = "rotation"
  return str
endfunction

function! python#xlrd#shrink_to_fit()
  let str = "shrink_to_fit"
  return str
endfunction

function! python#xlrd#text_direction()
  let str = "text_direction"
  return str
endfunction

function! python#xlrd#text_wrapped()
  let str = "text_wrapped"
  return str
endfunction

function! python#xlrd#vert_align()
  let str = "vert_align"
  return str
endfunction

function! python#xlrd#XFBackground()
  let str = "XFBackground"
  return str
endfunction

function! python#xlrd#background_colour_index()
  let str = "background_colour_index"
  return str
endfunction

function! python#xlrd#fill_pattern()
  let str = "fill_pattern"
  return str
endfunction

function! python#xlrd#pattern_colour_index()
  let str = "pattern_colour_index"
  return str
endfunction

function! python#xlrd#XFBorder()
  let str = "XFBorder"
  return str
endfunction

function! python#xlrd#bottom_colour_index()
  let str = "bottom_colour_index"
  return str
endfunction

function! python#xlrd#bottom_line_style()
  let str = "bottom_line_style"
  return str
endfunction

function! python#xlrd#diag_colour_index()
  let str = "diag_colour_index"
  return str
endfunction

function! python#xlrd#diag_down()
  let str = "diag_down"
  return str
endfunction

function! python#xlrd#diag_line_style()
  let str = "diag_line_style"
  return str
endfunction

function! python#xlrd#diag_up()
  let str = "diag_up"
  return str
endfunction

function! python#xlrd#left_colour_index()
  let str = "left_colour_index"
  return str
endfunction

function! python#xlrd#left_line_style()
  let str = "left_line_style"
  return str
endfunction

function! python#xlrd#right_colour_index()
  let str = "right_colour_index"
  return str
endfunction

function! python#xlrd#right_line_style()
  let str = "right_line_style"
  return str
endfunction

function! python#xlrd#top_colour_index()
  let str = "top_colour_index"
  return str
endfunction

function! python#xlrd#top_line_style()
  let str = "top_line_style"
  return str
endfunction

function! python#xlrd#XFProtection()
  let str = "XFProtection"
  return str
endfunction

function! python#xlrd#cell_locked()
  let str = "cell_locked"
  return str
endfunction

function! python#xlrd#formula_hidden()
  let str = "formula_hidden"
  return str
endfunction




unit Consts;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

  {%Region -fold Const}

const
  REPO = 'plaintool/pobatch';
  APP_NAME = 'pobatch';
  AppName = 'PoBatch';
  MAX_RECENT_FILES = 10;

  COLUMN_HEADERS_NAME = 0;
  COLUMN_HEADERS_VALUE = 1;
  CELL_HEADERS_NAME = 1;
  CELL_HEADERS_VALUE = 2;
  COLUMN_COMMENTS_TYPE = 0;
  COLUMN_COMMENTS_VALUE = 1;
  CELL_COMMENTS_TYPE = 1;
  CELL_COMMENTS_VALUE = 2;
  COLUMN_PLURAL_PLURAL = 0;
  CELL_PLURAL_PLURAL = 1;

  COLUMN_VALID = 0;
  COLUMN_TEXT = 1;
  COLUMN_TRANSLATION = 2;
  COLUMN_CONTEXT = 3;
  COLUMN_PLURAL = 4;
  COLUMN_REFERENCE = 5;
  COLUMN_FUZZY = 6;
  CELL_VALID = 1;
  CELL_TEXT = 2;
  CELL_TRANSLATION = 3;
  CELL_CONTEXT = 4;
  CELL_PLURAL = 5;
  CELL_REFERENCE = 6;
  CELL_FUZZY = 7;

  UNDEFINED = 'undefined';
  LANG_KEY_NONE = '*';

  {%EndRegion}

  {%Region -fold Resource Strings}
resourcestring
  rpotnotfound = 'POT file not found: %s';
  rnopofilesfound = 'No .po files found in the selected directory!';

  rdiscardchanges = 'Do you want to discard all unsaved changes?';

  rpluralformtitle = 'Plural form';
  rpluralformenter = 'Enter plural form';
  rdeletepluraltitle = 'Delete plural form?';
  rdeletepluralconfirm = 'Are you sure you want to delete this plural form?';

  rdeleterowtitle = 'Delete row';
  rdeleterowconfirm = 'Are you sure you want to delete the selected row?';
  rdeleterowsconfirm = 'Delete selected rows?';

  rsavechangestitle = 'Save Changes';
  rsavechangesmsg = 'The document "%s" has been modified.'#13#10'Do you want to save your changes?';
  runtitled = 'Untitled';
  rpathuntitled = '%s - Untitled';

  rerrortitle = 'Error';
  rerrornotexist = 'File does not exist:'#13#10'%s';
  rerrornotexistine = 'File does not exist: %s';
  ropenfiletitle = 'Open File';
  ropenfileunknown = 'The file "%s" has an unrecognized extension.'#13#10'Do you want to try opening it anyway?';
  rlargefiletitle = 'Large File';
  rlargefileconfirm = 'The file is very large (%d MB).'#13#10'Opening it may take a while. Continue?';
  rloaderrortitle = 'Load Error';
  rloaderrormsg = 'Error loading file:'#13#10'%s'#13#10'File may be corrupted or in wrong format.';
  rerrorinvalidfilename = 'Invalid file name';
  rsaveerrortitle = 'Save Error';
  rsaveerrormsg = 'Error saving file:'#13#10'%s';

  rrequiredparamtitle = 'Enter the required parameter';
  rrequiredparamprompt = 'Enter %s';

  rstatustranslated = 'Translated %d of %d (%d%%) Remaining %d';
  rstatusinvalid = 'Invalid: %d (Fuzzy %d, QA %d, Empty %d)';
  rstatustranslatedhint = 'Translation progress: translated entries of the total, percentage, remaining count';
  rstatusinvalidhint = 'Invalid entries: total count with a breakdown by fuzzy flag, QA issues and empty translations';
  rstatuscrlf = 'Windows (CRLF)';
  rstatuslf = 'Unix (LF)';
  rstatuscr = 'Mac (CR)';
  rstatuslineendinghint = 'Line ending style used when saving the file';

  rqacheckscaption = 'QA Checks';

  rgotoentrytitle = 'Go to entry';
  rgotoentryprompt = 'Enter entry number:';
  rinvalidnumber = 'Invalid number: %s';
  rnotfoundentry = 'Entry number %s not found.';

  ropenrecentclear = 'Clear List';

  rrememberfiletitle = 'Remember file';
  rrememberfiledone = 'Done. %d translation(s) remembered, %d skipped.';
  rrememberfilelangnotset = 'File "%s" skipped: target language is not set in the PO header.';

  rfilechangedtitle = 'File changed on disk';
  rfilechangedmsg = 'The file "%s" has been modified by another application since it was opened.';
  rfilechangedmsgsave = 'You have unsaved changes. What would you like to do?';
  rfilechangedmsgactivate = 'You have unsaved changes. Keep them or reload from disk?';
  rfilechangedoverwrite = 'Overwrite';
  rfilechangedreload = 'Reload';
  rfilechangedcancel = 'Cancel';
  rfilechangedkeepchanges = 'Keep my changes';
  rfilechangedreloaddisk = 'Reload from disk';
  rfilereloaded = 'File reloaded from disk';
  rcancelbatchtitle = 'Cancel operation';
  rcancelbatchconfirm = 'Do you want to cancel the current batch operation?';
  {%EndRegion}

implementation

end.

{ ****************************************************************************** }
{ * fast File query in Package                                                 * }
{ * https://zpascal.net                                                        * }
{ * https://github.com/PassByYou888/zAI                                        * }
{ * https://github.com/PassByYou888/ZServer4D                                  * }
{ * https://github.com/PassByYou888/PascalString                               * }
{ * https://github.com/PassByYou888/zRasterization                             * }
{ * https://github.com/PassByYou888/CoreCipher                                 * }
{ * https://github.com/PassByYou888/zSound                                     * }
{ * https://github.com/PassByYou888/zChinese                                   * }
{ * https://github.com/PassByYou888/zExpression                                * }
{ * https://github.com/PassByYou888/zGameWare                                  * }
{ * https://github.com/PassByYou888/zAnalysis                                  * }
{ * https://github.com/PassByYou888/FFMPEG-Header                              * }
{ * https://github.com/PassByYou888/zTranslate                                 * }
{ * https://github.com/PassByYou888/InfiniteIoT                                * }
{ * https://github.com/PassByYou888/FastMD5                                    * }
{ ****************************************************************************** }
(*
  update history
*)

unit LibraryManager;

{$INCLUDE zDefine.inc}

interface

uses ObjectDataManager, StreamList, CoreClasses, PascalStrings,
  UnicodeMixedLib;

type
  TLibraryManager = class(TCoreClassObject)
  private
    FList: TCoreClassListForObj;
    FDBEngine: TObjectDataManager;
    FRoot: THashStreamList;
    FRootDir: SystemString;
    FAutoFreeDataEngine: Boolean;
  private
  protected
    function GetItems(index: Integer): THashStreamList;
    function GetNameItems(AName: SystemString): THashStreamList;
    function GetPathItems(APath: SystemString): PHashStreamListData;
  public
    constructor Create(DataEngine_: TObjectDataManager; aRootDir: SystemString);
    destructor Destroy; override;
    function Clone: TLibraryManager;
    function Count: Integer;
    procedure Clear;
    procedure Refresh;
    procedure ChangeRoot(NewRoot: SystemString);

    function TotalCount: Integer;
    function new(AName, aDescription: SystemString): THashStreamList;
    function Delete(AName: SystemString; ForceRefresh: Boolean): Boolean;
    function ReName(aOLDName, NewName, aDescription: SystemString; ForceRefresh: Boolean): Boolean;
    function Exists(AName: SystemString): Boolean;

    property Items[index: Integer]: THashStreamList read GetItems;
    property NameItems[AName: SystemString]: THashStreamList read GetNameItems; default;
    property PathItems[APath: SystemString]: PHashStreamListData read GetPathItems;
    property DBEngine: TObjectDataManager read FDBEngine;
    property ROOT: THashStreamList read FRoot;
    property AutoFreeDataEngine: Boolean read FAutoFreeDataEngine write FAutoFreeDataEngine;
  end;

implementation

const
  PathDelim = ':\/';

var
  _LibManCloneAutoFreeList: TCoreClassListForObj = nil;

function LibManCloneAutoFreeList: TCoreClassListForObj;
begin
  if _LibManCloneAutoFreeList = nil then
      _LibManCloneAutoFreeList := TCoreClassListForObj.Create;
  Result := _LibManCloneAutoFreeList;
end;

procedure FreeLibManCloneAutoFreeList;
var
  i: Integer;
begin
  if _LibManCloneAutoFreeList = nil then
      Exit;
  i := 0;
  while i < _LibManCloneAutoFreeList.Count do
      DisposeObject(TLibraryManager(_LibManCloneAutoFreeList[i]));
  DisposeObject(_LibManCloneAutoFreeList);
  _LibManCloneAutoFreeList := nil;
end;

procedure DeleteLibManCloneFromAutoFreeList(p: TLibraryManager);
var
  i: Integer;
begin
  if _LibManCloneAutoFreeList = nil then
      Exit;
  i := 0;
  while i < _LibManCloneAutoFreeList.Count do
    begin
      if _LibManCloneAutoFreeList[i] = p then
          _LibManCloneAutoFreeList.Delete(i)
      else
          inc(i);
    end;
end;

function TLibraryManager.GetItems(index: Integer): THashStreamList;
begin
  Result := THashStreamList(FList[index]);
end;

function TLibraryManager.GetNameItems(AName: SystemString): THashStreamList;
var
  i: Integer;
begin
  Result := ROOT;
  if Count > 0 then
    for i := 0 to Count - 1 do
      if umlMultipleMatch(True, AName, Items[i].Name) then
        begin
          Result := Items[i];
          Break;
        end;
end;

function TLibraryManager.GetPathItems(APath: SystemString): PHashStreamListData;
var
  i: Integer;
  slst: THashStreamList;
  PhPrefix, phPostfix: SystemString;
begin
  Result := nil;
  if Count > 0 then
    begin
      if umlGetIndexStrCount(APath, PathDelim) > 1 then
          PhPrefix := umlGetFirstStr(APath, PathDelim).Text
      else
          PhPrefix := '';
      phPostfix := umlGetLastStr(APath, PathDelim).Text;
      for i := 0 to Count - 1 do
        begin
          if umlMultipleMatch(True, PhPrefix, Items[i].Name) then
            begin
              slst := Items[i];
              if slst <> nil then
                begin
                  Result := slst.Names[phPostfix];
                  if Result <> nil then
                      Break;
                end;
            end;
        end;
    end;
end;

constructor TLibraryManager.Create(DataEngine_: TObjectDataManager; aRootDir: SystemString);
begin
  inherited Create;
  FList := TCoreClassListForObj.Create;
  FDBEngine := DataEngine_;
  FRoot := nil;
  FRootDir := aRootDir;
  Refresh;
  LibManCloneAutoFreeList.Add(Self);
  FAutoFreeDataEngine := False;
end;

destructor TLibraryManager.Destroy;
begin
  DeleteLibManCloneFromAutoFreeList(Self);
  while FList.Count > 0 do
    begin
      DisposeObject(THashStreamList(FList[0]));
      FList.Delete(0);
    end;
  DisposeObject(FList);
  if FAutoFreeDataEngine then
      DisposeObject(FDBEngine);
  inherited Destroy;
end;

function TLibraryManager.Clone: TLibraryManager;
begin
  Result := TLibraryManager.Create(DBEngine, FRootDir);
end;

function TLibraryManager.Count: Integer;
begin
  Result := FList.Count;
end;

procedure TLibraryManager.Clear;
begin
  while Count > 0 do
    begin
      DisposeObject(THashStreamList(FList[0]));
      FList.Delete(0);
    end;
end;

procedure TLibraryManager.Refresh;
var
  fPos: Int64;
  hsList: THashStreamList;
  n, d: SystemString;
  fSearchHnd: TFieldSearch;
begin
  if FDBEngine.isAbort then
      Exit;
  while FList.Count > 0 do
    begin
      DisposeObject(THashStreamList(FList[0]));
      FList.Delete(0);
    end;

  if FDBEngine.FieldFindFirst(FRootDir, '*', fSearchHnd) then
    begin
      repeat
        n := fSearchHnd.Name;
        d := fSearchHnd.Description;
        fPos := fSearchHnd.HeaderPOS;
        hsList := THashStreamList.Create(FDBEngine, fPos);
        hsList.Name := n;
        hsList.Description := d;
        FList.Add(hsList);
      until not FDBEngine.FieldFindNext(fSearchHnd);
    end;

  if FDBEngine.GetPathField(FRootDir, fPos) then
    begin
      n := 'Root';
      d := '....';
      hsList := THashStreamList.Create(FDBEngine, fPos);
      hsList.Name := n;
      hsList.Description := d;
      if FList.Count > 0 then
          FList.Insert(0, hsList)
      else
          FList.Add(hsList);
      FRoot := hsList;
    end;
end;

procedure TLibraryManager.ChangeRoot(NewRoot: SystemString);
begin
  FRootDir := NewRoot;
  Refresh;
end;

function TLibraryManager.TotalCount: Integer;
var
  i: Integer;
begin
  Result := 0;
  if Count > 0 then
    for i := 0 to Count - 1 do
        Result := Result + Items[i].Count;
end;

function TLibraryManager.new(AName, aDescription: SystemString): THashStreamList;
var
  fPos: Int64;
  n, d: SystemString;
  fSearchHnd: TFieldSearch;
begin
  Result := nil;
  if not umlMultipleMatch(True, AName, ROOT.Name) then
    begin
      if FDBEngine.CreateField((FRootDir + '/' + AName), aDescription) then
        begin
          if FDBEngine.FieldFindFirst(FRootDir, AName, fSearchHnd) then
            begin
              n := fSearchHnd.Name;
              d := fSearchHnd.Description;
              fPos := fSearchHnd.HeaderPOS;
              Result := THashStreamList.Create(FDBEngine, fPos);
              Result.Name := n;
              Result.Description := d;
              FList.Add(Result);
            end;
        end;
    end
  else
    begin
      Result := ROOT;
    end;
end;

function TLibraryManager.Delete(AName: SystemString; ForceRefresh: Boolean): Boolean;
begin
  Result := FDBEngine.FieldDelete(FRootDir, AName);
  if (ForceRefresh) and (Result) then
      Refresh;
end;

function TLibraryManager.ReName(aOLDName, NewName, aDescription: SystemString; ForceRefresh: Boolean): Boolean;
var
  fPos: Int64;
begin
  Result := False;
  if FDBEngine.FieldExists(FRootDir, NewName) then
      Exit;
  if FDBEngine.GetPathField(FRootDir + '/' + aOLDName, fPos) then
    begin
      Result := FDBEngine.FieldReName(fPos, NewName, aDescription);
      if (Result) and (ForceRefresh) then
          Refresh;
    end;
end;

function TLibraryManager.Exists(AName: SystemString): Boolean;
var
  i: Integer;
begin
  Result := False;
  if Count > 0 then
    for i := 0 to Count - 1 do
      begin
        if umlMultipleMatch(True, AName, Items[i].Name) then
          begin
            Result := True;
            Exit;
          end;
      end;
end;

initialization

finalization

FreeLibManCloneAutoFreeList;

end.

{ ****************************************************************************** }
{ * fast StreamQuery,writen by QQ 600585@qq.com                                * }
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

unit StreamList;

{$INCLUDE zDefine.inc}

interface

uses SysUtils, ObjectDataManager, ItemStream, CoreClasses, PascalStrings, ListEngine;

type
  THashStreamList = class;

  THashStreamListData = record
    qHash: THash;
    LowerCaseName, OriginName: SystemString;
    stream: TItemStream;
    ItemHnd: TItemHandle;
    CallCount: Integer;
    ForceFreeCustomObject: Boolean;
    CustomObject: TCoreClassObject;
    ID: Integer;
    Owner: THashStreamList;
  end;

  PHashStreamListData = ^THashStreamListData;

  THashStreamList = class(TCoreClassObject)
  protected
    FCounter: Boolean;
    FCount: Integer;
    FName: SystemString;
    FDescription: SystemString;
    FDBEngine: TObjectDataManager;
    FFieldPos: Int64;
    FAryList: array of TCoreClassList;
    FData: Pointer;

    function GetListTable(hash: THash; AutoCreate: Boolean): TCoreClassList;
    procedure RefreshDBLst(DBEngine_: TObjectDataManager; var aFieldPos: Int64);
  public
    constructor Create(DBEngine_: TObjectDataManager; aFieldPos: Int64);
    destructor Destroy; override;
    procedure Clear;
    procedure Refresh;
    procedure GetOriginNameListFromFilter(aFilter: SystemString; OutputList: TCoreClassStrings);
    procedure GetListFromFilter(aFilter: SystemString; OutputList: TCoreClassList);
    procedure GetOriginNameList(OutputList: TCoreClassStrings); overload;
    procedure GetOriginNameList(OutputList: TListString); overload;
    procedure GetList(OutputList: TCoreClassList);
    function Find(AName: SystemString): PHashStreamListData;
    function Exists(AName: SystemString): Boolean;

    procedure SetHashBlockCount(cnt: Integer);

    function GetItem(AName: SystemString): PHashStreamListData;
    property Names[AName: SystemString]: PHashStreamListData read GetItem; default;

    property DBEngine: TObjectDataManager read FDBEngine;
    property FieldPos: Int64 read FFieldPos;
    property Name: SystemString read FName write FName;
    property Description: SystemString read FDescription write FDescription;
    property Counter: Boolean read FCounter write FCounter;
    property Count: Integer read FCount;
    property Data: Pointer read FData write FData;
  end;

implementation

uses UnicodeMixedLib;

constructor THashStreamList.Create(DBEngine_: TObjectDataManager; aFieldPos: Int64);
begin
  inherited Create;
  FCounter := True;
  FCount := 0;
  FData := nil;
  SetLength(FAryList, 0);
  SetHashBlockCount(10000);
  RefreshDBLst(DBEngine_, aFieldPos);
end;

destructor THashStreamList.Destroy;
begin
  Clear;
  inherited Destroy;
end;

procedure THashStreamList.Clear;
var
  i: Integer;
  Rep_Int_Index: Integer;
begin
  FCount := 0;
  if length(FAryList) = 0 then
      Exit;

  for i := low(FAryList) to high(FAryList) do
    begin
      if FAryList[i] <> nil then
        begin
          with FAryList[i] do
            begin
              if Count > 0 then
                begin
                  for Rep_Int_Index := 0 to Count - 1 do
                    begin
                      with PHashStreamListData(Items[Rep_Int_Index])^ do
                        begin
                          if stream <> nil then
                            begin
                              DisposeObject(stream);
                              if (ForceFreeCustomObject) and (CustomObject <> nil) then
                                begin
                                  try
                                    DisposeObject(CustomObject);
                                    CustomObject := nil;
                                  except
                                  end;
                                end;
                            end;
                        end;
                      try
                          Dispose(PHashStreamListData(Items[Rep_Int_Index]));
                      except
                      end;
                    end;
                end;
            end;

          DisposeObject(FAryList[i]);
          FAryList[i] := nil;
        end;
    end;
end;

function THashStreamList.GetListTable(hash: THash; AutoCreate: Boolean): TCoreClassList;
var
  idx: Integer;
begin
  idx := hashMod(hash, length(FAryList));

  if (AutoCreate) and (FAryList[idx] = nil) then
      FAryList[idx] := TCoreClassList.Create;
  Result := FAryList[idx];
end;

procedure THashStreamList.RefreshDBLst(DBEngine_: TObjectDataManager; var aFieldPos: Int64);
var
  ItemSearchHnd: TItemSearch;
  ICnt: Integer;

  procedure AddLstItem(_ItemPos: Int64);
  var
    newhash: THash;
    p: PHashStreamListData;
    idxLst: TCoreClassList;
    lName: SystemString;
    ItemHnd: TItemHandle;
  begin
    if FDBEngine.ItemFastOpen(_ItemPos, ItemHnd) then
      if umlGetLength(ItemHnd.Name) > 0 then
        begin
          lName := ItemHnd.Name.LowerText;
          newhash := MakeHashS(@lName);
          idxLst := GetListTable(newhash, True);
          new(p);
          p^.qHash := newhash;
          p^.LowerCaseName := lName;
          p^.OriginName := ItemHnd.Name;
          p^.stream := nil;
          p^.ItemHnd := ItemHnd;
          p^.CallCount := 0;
          p^.ForceFreeCustomObject := False;
          p^.CustomObject := nil;
          p^.ID := ICnt;
          p^.Owner := Self;
          idxLst.Add(p);
          inc(ICnt);
        end;
  end;

begin
  FDBEngine := DBEngine_;
  FFieldPos := aFieldPos;
  FCount := 0;
  ICnt := 0;
  if FDBEngine.ItemFastFindFirst(FFieldPos, '*', ItemSearchHnd) then
    begin
      repeat
        inc(FCount);
        AddLstItem(ItemSearchHnd.HeaderPOS);
      until not FDBEngine.ItemFastFindNext(ItemSearchHnd);
    end;
end;

procedure THashStreamList.Refresh;
begin
  Clear;
  RefreshDBLst(FDBEngine, FFieldPos);
end;

procedure THashStreamList.GetOriginNameListFromFilter(aFilter: SystemString; OutputList: TCoreClassStrings);
var
  i: Integer;
  L: TCoreClassList;
  p: PHashStreamListData;
begin
  L := TCoreClassList.Create;
  GetList(L);

  OutputList.Clear;
  if L.Count > 0 then
    for i := 0 to L.Count - 1 do
      begin
        p := PHashStreamListData(L[i]);
        if umlMultipleMatch(aFilter, p^.OriginName) then
            OutputList.Add(p^.OriginName);
      end;

  DisposeObject(L);
end;

procedure THashStreamList.GetListFromFilter(aFilter: SystemString; OutputList: TCoreClassList);
var
  i: Integer;
  L: TCoreClassList;
  p: PHashStreamListData;
begin
  L := TCoreClassList.Create;
  GetList(L);

  OutputList.Clear;
  if L.Count > 0 then
    for i := 0 to L.Count - 1 do
      begin
        p := PHashStreamListData(L[i]);
        if umlMultipleMatch(aFilter, p^.OriginName) then
            OutputList.Add(p);
      end;

  DisposeObject(L);
end;

procedure THashStreamList.GetOriginNameList(OutputList: TCoreClassStrings);
var
  i: Integer;
  L: TCoreClassList;
begin
  L := TCoreClassList.Create;
  GetList(L);

  OutputList.Clear;
  if L.Count > 0 then
    for i := 0 to L.Count - 1 do
        OutputList.Add(PHashStreamListData(L[i])^.OriginName);

  DisposeObject(L);
end;

procedure THashStreamList.GetOriginNameList(OutputList: TListString);
var
  i: Integer;
  L: TCoreClassList;
begin
  L := TCoreClassList.Create;
  GetList(L);

  OutputList.Clear;
  if L.Count > 0 then
    for i := 0 to L.Count - 1 do
        OutputList.Add(PHashStreamListData(L[i])^.OriginName);

  DisposeObject(L);
end;

procedure THashStreamList.GetList(OutputList: TCoreClassList);
  function ListSortCompare(Item1, Item2: Pointer): Integer;
    function aCompareValue(const a, b: Int64): Integer;
    begin
      if a = b then
          Result := 0
      else if a < b then
          Result := -1
      else
          Result := 1;
    end;

  begin
    Result := aCompareValue(PHashStreamListData(Item1)^.ID, PHashStreamListData(Item2)^.ID);
  end;

  procedure QuickSortList(var SortList: TCoreClassPointerList; L, r: Integer);
  var
    i, j: Integer;
    p, t: Pointer;
  begin
    repeat
      i := L;
      j := r;
      p := SortList[(L + r) shr 1];
      repeat
        while ListSortCompare(SortList[i], p) < 0 do
            inc(i);
        while ListSortCompare(SortList[j], p) > 0 do
            dec(j);
        if i <= j then
          begin
            if i <> j then
              begin
                t := SortList[i];
                SortList[i] := SortList[j];
                SortList[j] := t;
              end;
            inc(i);
            dec(j);
          end;
      until i > j;
      if L < j then
          QuickSortList(SortList, L, j);
      L := i;
    until i >= r;
  end;

var
  i: Integer;
  Rep_Int_Index: Integer;
begin
  OutputList.Clear;

  if Count > 0 then
    begin
      OutputList.Capacity := Count;

      for i := low(FAryList) to high(FAryList) do
        begin
          if FAryList[i] <> nil then
            begin
              with FAryList[i] do
                if Count > 0 then
                  begin
                    for Rep_Int_Index := 0 to Count - 1 do
                      with PHashStreamListData(Items[Rep_Int_Index])^ do
                        begin
                          if stream = nil then
                              stream := TItemStream.Create(FDBEngine, ItemHnd)
                          else
                              stream.SeekStart;
                          if FCounter then
                              inc(CallCount);
                          OutputList.Add(Items[Rep_Int_Index]);
                        end;
                  end;
            end;
        end;

      if OutputList.Count > 1 then
          QuickSortList(OutputList.ListData^, 0, OutputList.Count - 1);
    end;
end;

function THashStreamList.Find(AName: SystemString): PHashStreamListData;
var
  i: Integer;
  Rep_Int_Index: Integer;
begin
  Result := nil;
  for i := low(FAryList) to high(FAryList) do
    begin
      if FAryList[i] <> nil then
        begin
          with FAryList[i] do
            if Count > 0 then
              begin
                for Rep_Int_Index := 0 to Count - 1 do
                  begin
                    if umlMultipleMatch(True, AName, PHashStreamListData(Items[Rep_Int_Index])^.OriginName) then
                      begin
                        Result := Items[Rep_Int_Index];
                        if Result^.stream = nil then
                            Result^.stream := TItemStream.Create(FDBEngine, Result^.ItemHnd)
                        else
                            Result^.stream.SeekStart;
                        if FCounter then
                            inc(Result^.CallCount);
                        Exit;
                      end;
                  end;
              end;
        end;
    end;
end;

function THashStreamList.Exists(AName: SystemString): Boolean;
var
  newhash: THash;
  i: Integer;
  idxLst: TCoreClassList;
  lName: SystemString;
begin
  Result := False;
  if umlGetLength(AName) > 0 then
    begin
      lName := LowerCase(AName);
      newhash := MakeHashS(@lName);
      idxLst := GetListTable(newhash, False);
      if idxLst <> nil then
        if idxLst.Count > 0 then
          for i := 0 to idxLst.Count - 1 do
            if (newhash = PHashStreamListData(idxLst[i])^.qHash) and (PHashStreamListData(idxLst[i])^.LowerCaseName = lName) then
                Exit(True);
    end;
end;

procedure THashStreamList.SetHashBlockCount(cnt: Integer);
var
  i: Integer;
begin
  Clear;
  SetLength(FAryList, cnt);
  for i := low(FAryList) to high(FAryList) do
      FAryList[i] := nil;
end;

function THashStreamList.GetItem(AName: SystemString): PHashStreamListData;
var
  newhash: THash;
  i: Integer;
  idxLst: TCoreClassList;
  lName: SystemString;
begin
  Result := nil;
  if umlGetLength(AName) > 0 then
    begin
      lName := LowerCase(AName);
      newhash := MakeHashS(@lName);
      idxLst := GetListTable(newhash, False);
      if idxLst <> nil then
        if idxLst.Count > 0 then
          for i := 0 to idxLst.Count - 1 do
            begin
              if (newhash = PHashStreamListData(idxLst[i])^.qHash) and (PHashStreamListData(idxLst[i])^.LowerCaseName = lName) then
                begin
                  Result := idxLst[i];
                  if Result^.stream = nil then
                      Result^.stream := TItemStream.Create(FDBEngine, Result^.ItemHnd)
                  else
                      Result^.stream.SeekStart;
                  if FCounter then
                      inc(Result^.CallCount);
                  Exit;
                end;
            end;
    end;
end;

end.

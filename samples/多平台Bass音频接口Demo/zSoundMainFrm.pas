unit zSoundMainFrm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.ScrollBox, FMX.Memo,

  MediaCenter, zSound_Bass;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Memo1: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.Button1Click(Sender: TObject);
begin
  Media.PlayMusic('Music.mp3');
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  Media.StopMusic;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  Media.PlayAmbient('Ambient.mp3');
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  Media.StopAmbient;
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  Media.PlaySound('hit.mp3');
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
  Media.StopSound('hit.mp3');
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  // 自动初始化以Sound.ox命名的音频资源包
  // 资源包是使用打包工具制作的，在Tools目录有打包工具源码
  InitGlobalMedia([gmtSound]);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FreeGlobalMedia;
end;

end.

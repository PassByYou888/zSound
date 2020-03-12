unit zSoundMainFrm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.ScrollBox, FMX.Memo,

  MediaCenter, zSound_FMX, zSound;

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
function media: TzSound;

implementation

{$R *.fmx}

function media: TzSound;
begin
  Result:=SoundEngine_FMX;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  media.PlayMusic('Music.mp3');
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  media.StopMusic;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  media.PlayAmbient('Ambient.mp3');
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  media.StopAmbient;
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  media.PlaySound('hit.wav');
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
  media.StopSound('hit.wav');
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  // �Զ���ʼ����Sound.ox��������Ƶ��Դ��
  // ��Դ����ʹ�ô�����������ģ���ToolsĿ¼�д������Դ��
  InitGlobalMedia([gmtSound]);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FreeGlobalMedia;
end;

end.

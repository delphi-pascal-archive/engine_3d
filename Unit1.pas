unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OpenGL, ExtCtrls, Math;

type
  TForm1 = class(TForm)
    Timer1: TTimer;
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

type
  User=record
    Position:record
      x,y,z:Single;
    end;
    Rotation:record
      y,zx:Single;
    end;
  end;

var
  Form1: TForm1;
  DC:HDC;
  HRC:HGLRC;
  Human:User;

implementation

{$R *.dfm}

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
const
  SPEED=0.2;
begin
  case key of
    27: Form1.Close;
    37: begin
          Human.Position.z:=Human.Position.z+
          sin(DegToRad(Human.Rotation.y))*SPEED;
          Human.Position.x:=Human.Position.x+
          cos(DegToRad(Human.Rotation.y))*SPEED;
        end;
    38: begin
          Human.Position.z:=Human.Position.z+
          cos(DegToRad(Human.Rotation.y))*SPEED;
          Human.Position.x:=Human.Position.x-
          sin(DegToRad(Human.Rotation.y))*SPEED;
        end;
    39: begin
          Human.Position.z:=Human.Position.z-
          sin(DegToRad(Human.Rotation.y))*SPEED;
          Human.Position.x:=Human.Position.x-
          cos(DegToRad(Human.Rotation.y))*SPEED;
        end;
    40: begin
          Human.Position.z:=Human.Position.z-
          cos(DegToRad(Human.Rotation.y))*SPEED;
          Human.Position.x:=Human.Position.x+
          sin(DegToRad(Human.Rotation.y))*SPEED;
        end;
  end;
end;

procedure SetDCPixelFormat;
var
  pfd:TPixelFormatDescriptor;
  nPixelFormat:Integer;
begin
  FillChar(pfd,SizeOf(pfd),0);
  pfd.dwFlags:=PFD_DRAW_TO_WINDOW or
               PFD_DOUBLEBUFFER or
               PFD_SUPPORT_OPENGL;
  nPixelFormat:=ChoosePixelFormat(DC,@pfd);
  SetPixelFormat(DC,nPixelFormat,@pfd);
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  i:Integer;
begin
  DC:=GetDC(Handle);
  SetDCPixelFormat;
  HRC:=wglCreateContext(DC);
  wglMakeCurrent(DC,HRC);
  Form1.WindowState:=wsMaximized;
  ShowCursor(False);
  glClearColor(0.0,0.0,0.0,1.0);
  glEnable(GL_DEPTH_TEST);
  glNewList(1,GL_COMPILE);
    glBegin(GL_LINES);
      glColor3f(0.7,1.0,0.7);
      for i:=-50 to 50 do
      begin
        glVertex3f(-50,-1,i);
        glVertex3f(50,-1,i);
        glVertex3f(i,-1,-50);
        glVertex3f(i,-1,50);
      end;
    glEnd;
  glEndList;
  with Human do
  begin
    with Position do
    begin
      x:=0;
      y:=0;
      z:=0;
    end;
    with Rotation do
    begin
      y:=0;
      zx:=0;
    end;
  end;
  SetCursorPos(Round(Form1.ClientWidth/2),
               Round(Form1.ClientHeight/2));
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  wglMakeCurrent(0,0);
  wglDeleteContext(HRC);
  ReleaseDC(Handle,DC);
  DeleteDC(DC);
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  SetCursorPos(Round(Form1.ClientWidth/2),
               Round(Form1.ClientHeight/2));
  InvalidateRect(Handle,nil,false);
end;

procedure TForm1.FormResize(Sender: TObject);
begin
  glViewport(0, 0, ClientWidth, ClientHeight);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPerspective(30.0, ClientWidth / ClientHeight, 0.1, 1000.0);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
end;

procedure TForm1.FormPaint(Sender: TObject);
var
  ps:TPaintStruct;
begin
  BeginPaint(Handle,ps);
  glClear(GL_COLOR_BUFFER_BIT or
          GL_DEPTH_BUFFER_BIT);

  glLoadIdentity;
  glRotatef(Human.Rotation.zx,Abs(cos(DegToRad(Human.Rotation.y))),0,0);
  glRotatef(Human.Rotation.y,0,1,0);
  glTranslatef(Human.Position.x,
               Human.Position.y,
               Human.Position.z);

  glCallList(1);

  EndPaint(Handle,ps);
  SwapBuffers(DC);
end;

procedure TForm1.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
const
  Divider=8;
begin
  Human.Rotation.y:=Human.Rotation.y+
      Round((Mouse.CursorPos.X-Round(Form1.ClientWidth/2))/Divider);
  if Human.Rotation.y>=360 then Human.Rotation.y:=0;
  if Human.Rotation.y<0 then Human.Rotation.y:=360;

  Human.Rotation.zx:=Human.Rotation.zx+
      Round((Mouse.CursorPos.Y-Round(Form1.ClientHeight/2))/Divider);
  if Human.Rotation.zx>90 then Human.Rotation.zx:=90;
  if Human.Rotation.zx<-90 then Human.Rotation.zx:=-90;
end;

end.

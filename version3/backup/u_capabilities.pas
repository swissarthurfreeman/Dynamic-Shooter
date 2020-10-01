unit U_Capabilities;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ExtCtrls, Graphics;

type
  TPowerups = Class
    private
      pictures: TImage;
    public
      coolDownTimer:TTimer;
      shieldImage:TImage;
      powerCoolDown:integer;
      procedure onCoolDown(Sender:TObject);
      constructor create(); overload;
      procedure jetAttack();
      procedure invisibility();
      procedure shield(shieldPic:TImage; player:TImage);
      procedure mines();
  end;

const
  BASE_COOLDOWN = 5;

implementation

constructor TPowerups.create();
begin
  coolDownTimer:=TTimer.create(nil);
  coolDownTimer.Interval:=1000;

  //coolDownTimer.OnTimer:= onCoolDown;
end;

procedure TPowerups.onCoolDown(Sender:TObject);
begin

end;

procedure TPowerups.jetAttack();
begin

end;

procedure TPowerups.invisibility();
begin

end;

procedure TPowerups.shield(shieldPic:TImage; player:TImage);
begin
  //Je dois l'initialiser la créé!
  shieldPic.Picture.LoadFromFile('./ressources/shield.bmp');
  shieldPic.height:= 20;
  shieldPic.width:= 100;
  self.shieldImage:= shieldPic;
  self.shieldImage.Left:= player.left - self.shieldImage.width div 4;
  self.shieldImage.top:= player.top - self.shieldImage.height;
end;

procedure TPowerups.mines();
begin

end;

end.

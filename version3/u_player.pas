{***************************************************************
 * Description : DynamicShooterGame, class to manage players.  *
 * Author      : Arthur Freeman                                *
 * Date        : 8.22.2018                                     *
 * Version     : 8.1.                                          *
 ***************************************************************}
unit U_Player;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ExtCtrls, Windows;

type
  TShield = Record  //Record pour gérer le cooldown, la vie et l'image de mon bouclier.
   vie:integer;
   image:TImage;
   coolDown:integer;
end;

type
  TMines = Record    //Record pour gérer les mines.
    degats:integer;
    imageMine:TImage;
    v_x:integer;
    v_y:integer;
end;

type
  TPlayer = Record
   vie:integer;
   image:TImage;
   shield:TShield; //On passe un record à un record.
   laser:TImage;
   laserCoolDown:integer;
   mines:array[0..30] of TMines; //Même chose ici.
   minesCoolDown:integer;
   jet:TImage;
   xp_speed:integer;
   yp_speed:integer;
   shootCoolDown:integer;
   jetCoolDown:integer;
   tempsDeTir:integer;
   vitesse_maximale_joueur:integer;
   activeMines:boolean;
   beenLoaded:boolean;
end;

type              //Classe TPlayerObject, qui gère les joueurs.
  TPlayerObject = class
  private
    players: array of TPlayer;
  public
    nbMines:integer;
    nbJoueurs: integer;
    confirmedDestruction:boolean;
    constructor Create(picture:TImage);
    procedure setVieAt(player:integer; newVie:integer);
    procedure setImageAt(player: integer; picture: TImage);
    procedure addPlayer(newPlayer: TPlayer);
    procedure DeplacementGauche(player:integer);
    procedure DeplacementDroit(player:integer);
    procedure DeplacementAvant(player:integer);
    procedure DeplacementArriere(player:integer);
    procedure move(player:integer);
    procedure animate(player:integer);
    procedure collisions(player:integer);
    procedure setShootCoolDownAt(player:integer; newCoolDown:integer);
    procedure setTempsDeTirAt(player:integer; newTempsDeTir:integer);
    procedure jetAttack(player:integer);
    procedure laserAttack(player:integer);
    procedure setLaserCoolDown(player:integer; coolDown:integer);
    procedure shield(player:integer);
    procedure setShieldLifeAt(player:integer; newVie:integer);
    procedure mines(player:integer);
    procedure setMaximalSpeedAt(player:integer; vitesseMax:integer);
    procedure activatePowers(player:integer);
    function getJetCoolDownAt(player:integer):integer;
    function getImageAt(player: integer): TImage;
    function getVieAt(player:integer): integer;
    function inertie(vitesse:integer): integer;
    function max_speed(vitesse:integer; speed:integer): integer;
    function getShootCoolDown(player:integer):integer;
    function getTempsDeTir(player:integer):integer;
    function getShieldAt(player:integer):TShield;
    function getLaserAt(player:integer):TImage;
    function getMinesAt(player:integer; nbMine:integer):TImage;
    function getMaxSpeed(player:integer):integer;
  end;

const
  INITIAL_PLAYERS = 0;
  JOUEUR_1 = 0;
  JOUEUR_2 = 1;
  DEPLACEMENT = 60;

var bottombar:TImage;
    nb:integer;
    vitesse_maximale_joueur: integer;

implementation

constructor TPlayerObject.Create(picture:TImage);
begin
  //inherited;
  SetLength(self.players, INITIAL_PLAYERS);
  self.nbJoueurs:= 0;

  //On récupère l'image bottombar pour pouvoir lire ses propriétés dans U_Player.
  if nb < 1 then
    bottombar:= picture;
    nb:= nb + 1
end;

//Procédure qui gère les cooldowns des jets de tirs.
procedure TPlayerObject.jetAttack(player:integer);
begin
  players[player].jetCoolDown:= 100;
end;

//Procédure qui gère l'initialisation du bouclier.
procedure TPlayerObject.shield(player:integer);
begin
  //Si le cooldown est nul.
  if players[player].shield.coolDown <= 0 then
  begin
    //On règle la vie du bouclier.
    players[player].shield.vie:=20;
    //On le rends visible (l'image est configurée dans createPlayer dans U_Game)
    players[player].shield.image.visible:=true;
    //On réinitialise son cooldown.
    players[player].shield.coolDown:=600;
    players[player].shield.image.picture.loadFromFile('./ressources/powers/shield/shield1.bmp');
    players[player].beenLoaded:=false;
  end;
end;

//Fonction getter qui me renvoie la valeur du jetCoolDown.
function TPlayerObject.getJetCoolDownAt(player:integer):integer;
begin
  Result:=players[player].jetCoolDown;
end;

//Fonction getter qui me renvoie le TShield.
function TPlayerObject.getShieldAt(player:integer):TShield;
begin
  Result:= players[player].shield;
end;

//Procédure qui règle la vie du bouclier.
procedure TPlayerObject.setShieldLifeAt(player:integer; newVie:integer);
begin
  players[player].shield.vie:= newVie;
end;

//Procédure qui initialise le laser.
procedure TPlayerObject.laserAttack(player:integer);
begin
  players[player].vitesse_maximale_joueur:=4; //Je règle la vitesse maximale du joueur.
  players[player].laser.visible:= true;       //Je le rends visible.
  players[player].laserCoolDown:=500;         //Je règle son cooldown.
end;

//Fonction pour récupérer la valeur de la vitesse maximale du joueur.
function TPlayerObject.getMaxSpeed(player:integer):integer;
begin
  Result:=players[player].vitesse_maximale_joueur;
end;

//Procédure qui règle la vitesse maximale du joueur.
procedure TPlayerObject.setMaximalSpeedAt(player:integer; vitesseMax:integer);
begin
  players[player].vitesse_maximale_joueur:=vitesseMax;
end;

//Procédure qui règle le cooldown du joueur.
procedure TPlayerObject.setLaserCoolDown(player:integer; coolDown:integer);
begin
  players[player].laserCoolDown:=coolDown;
end;

//Fonction qui renvoie l'image du laser du joueur.
function TPlayerObject.getLaserAt(player:integer):TImage;
begin
  Result:= players[player].laser;
end;

//Procédure qui initialise les mines.
procedure TPlayerObject.mines(player:integer);
var
  i:integer;
begin
  //On parcoure le tableau des mines.
  for i:=0 to length(players[player].mines) - 1 do
  begin
    if players[player].minesCoolDown <= 0 then
    begin
      //On les rends actives.
      players[player].activeMines:=true;
      //On configure leur position initiale.
      players[player].mines[i].imageMine.top:= players[player].image.top;
      players[player].mines[i].imageMine.left:= players[player].image.left;
      //On les rends visibles.
      players[player].mines[i].imageMine.Visible:=true;
    end;
  end;
  //On règle leur cooldown.
  players[player].minesCoolDown:= 250;
end;

//Fonction qui renvoie les mines.
function TPlayerObject.getMinesAt(player:integer; nbMine:integer):TImage;
begin
  Result:= players[player].mines[nbMine].imageMine;
end;

procedure TPlayerObject.move(player:integer);
begin
  //On change la position avec la vitesse pour chaque axe du joueur.
  players[player].image.left := players[player].image.left + players[player].xp_speed;
  players[player].image.top := players[player].image.top + players[player].yp_speed;

  //Si c'est le joueur 1, on déplace avec WASD.
  if player = 0 then
  begin
    if(GetKeyState(ord('D')) < 0) then
       DeplacementDroit(player);

    if(GetKeyState(ord('A')) < 0) then
       DeplacementGauche(player);

    if(GetKeyState(ord('W')) < 0) then
       DeplacementAvant(player);

    if(GetKeyState(ord('S')) < 0) then
       DeplacementArriere(player);
  end;

  //Si c'est le joueur 2, on déplace avec les flèches.
  if player = 1 then
  begin
    //Déplacements du deuxième player.
    if(GetKeyState(ord(VK_RIGHT)) < 0) then
       DeplacementDroit(player);

    if(GetKeyState(ord(VK_LEFT)) < 0) then
       DeplacementGauche(player);

    if(GetKeyState(ord(VK_UP)) < 0) then
       DeplacementAvant(player);

    if(GetKeyState(ord(VK_DOWN)) < 0) then
       DeplacementArriere(player);
  end;

  //Animations du player (inertie de déplacement).
  animate(player);

  //Collisions du player avec les murs.
  collisions(player);
end;

//Procédure qui gère tous les pouvoirs des joueurs.
procedure TPlayerObject.activatePowers(player:integer);
var
  i:integer;
begin
  //On positione le bouclier sur le joueur.
  players[player].shield.image.top:=players[player].image.top - players[player].shield.image.height;
  players[player].shield.image.left:=players[player].image.left - players[player].shield.image.width div 4;

  //On positione le laser sur le joueur.
  players[player].laser.top:=players[player].image.top - players[player].laser.height;
  players[player].laser.left:=players[player].image.left;

  //Si c'est le joueur 1, les pouvoirs sont gérés par les touches 1,2,3 et 4.
  if player = 0 then
  begin
    //Pouvoirs du premier joueur.
    //Algorithme de coolDown de mines.
    if(GetKeyState(ord('3')) < 0) then
      if players[player].minesCoolDown <= 0 then
        mines(player);

    //Si j'appuie sur 4, je change le temps de tir de mes joueurs.
    if(GetKeyState(ord('4')) < 0) then
    begin
      if players[player].jetCoolDown = 0 then
        players[player].tempsDeTir:=1;
        //Je règle le coolDown.
        players[player].jetCoolDown:=200;
    end;

    //Si j'appuie sur 2, j'active l'attaque du laser.
    if(GetKeyState(ord('2')) < 0) then
    begin
      //Si le cooldown est nul, alors je peux attaquer.
      if players[player].laserCoolDown <= 0 then
      begin
        laserAttack(player);
      end;
    end;

    //Si j'appuie sur 1, j'active le bouclier.
    if(GetKeyState(ord('1')) < 0) then
      shield(player);
  end;

  //Idem mais avec d'autres touches pour le deuxième joueur.
  if player = 1 then
  begin
    //Pouvoirs du deuxième joueur.
    if(GetKeyState(ord(VK_NUMPAD3)) < 0) then
      if players[player].minesCoolDown <= 0 then
        mines(player);

    if(GetKeyState(ord(VK_NUMPAD4)) < 0) then
    begin
      if players[player].jetCoolDown = 0 then
        players[player].tempsDeTir:=1;
        players[player].jetCoolDown:=200;
    end;

    if(GetKeyState(ord(VK_NUMPAD2)) < 0) then
    begin
      //Si le cooldown est nul, alors je peux attaquer.
      if players[player].laserCoolDown <= 0 then
      begin
        laserAttack(player);
      end;
    end;

    if(GetKeyState(ord(VK_NUMPAD1)) < 0) then
      shield(player);
  end;

  //On gère le cooldown du bouclier ici.
  if (players[player].shield.coolDown > 0) and not (players[player].shield.image.visible) then
    players[player].shield.coolDown:= players[player].shield.coolDown - 1;

  if (players[player].shield.vie <= 10) and not (players[player].BeenLoaded) then
  begin
    players[player].shield.image.picture.loadFromFile('./ressources/powers/shield/shield2.bmp');
    players[player].BeenLoaded:=true;
  end;

  //On décrémente le cooldown du laser.
  if players[player].laserCoolDown > 0 then
    players[player].laserCoolDown:= players[player].laserCoolDown - 1;

  //Si le laser n'est pas actif, alors on règle la vitesse maximale.
  if players[player].laser.Visible = false then
    players[player].vitesse_maximale_joueur:=8;


  //Déplacement des mines.
  if players[player].activeMines = true then
  begin
    for i:=0 to length(players[player].mines) - 1 do
    begin
      //Si les mines sont actives, je les déplace avec leurs vitesses respectives en x et en y.
      players[player].mines[i].imageMine.top:= players[player].mines[i].imageMine.top + players[player].mines[i].v_y;
      players[player].mines[i].imageMine.left:= players[player].mines[i].imageMine.left + players[player].mines[i].v_x;
    end;
  end;
  self.nbMines:=length(players[player].mines);

  //On décrémente le cooldown des mines.
  if players[player].minesCoolDown > 0 then
    players[player].minesCoolDown:=players[player].minesCoolDown - 1;

  //On décrémente le cooldown du jet.
  if players[player].jetCoolDown > 0 then
    players[player].jetCoolDown:= players[player].jetCoolDown - 1;

  //Si le cooldown du laser est à la moitié, je le despawn.
  if players[player].laserCoolDown <= 250 then
    players[player].laser.visible:= false;

end;

//Procédure qui gère les collisions du joueur.
procedure TPlayerObject.collisions(player:integer);
begin
  if bottombar.visible then
  begin
    if(players[player].image.top + players[player].image.Height >= bottombar.top) then
      players[player].image.top := bottombar.top - players[player].image.height;
  end
  else  //Si la barre du bas n'est pas visible, c'est la séquence de réparation, donc on fait les collisions avec le cadre.
  begin
    if(players[player].image.top + players[player].image.height >= 700) then
      players[player].image.top:=700-players[player].image.height;
  end;

  if(players[player].image.left <= 0) then
    players[player].image.left := 0;

  if(players[player].image.left + players[player].image.width >= 600) then
    players[player].image.left := 600 - players[player].image.width;

  if(players[player].image.top <= 0) then
    players[player].image.top := 0;
end;

//Procédure qui appele les procédures qui gèrent l'intertie de déplacement du joueur.
procedure TPlayerObject.animate(player:integer);
begin
  //Si la vitesse est plus petite que zéro, alors il faut incrémenter.
  players[player].yp_speed:=max_speed(players[player].yp_speed, players[player].vitesse_maximale_joueur);
  players[player].yp_speed:=inertie(players[player].yp_speed);

  players[player].xp_speed:=max_speed(players[player].xp_speed, players[player].vitesse_maximale_joueur);
  players[player].xp_speed:=inertie(players[player].xp_speed);
end;

//Fonction qui gère la vitesse maximale.
function TPlayerObject.max_speed(vitesse:integer; speed:integer): integer;
begin
   if vitesse < -speed then
    vitesse:= -speed;

  if vitesse > speed then
    vitesse:= speed;

  result:=vitesse;
end;

//Fonction qui gère l'intertie.
function TPlayerObject.Inertie(vitesse:integer): integer;
begin
   //Si la vitesse est plus petite que zéro, alors il faut incrémenter.
  if vitesse < 0 then
  begin
     vitesse:= vitesse + 1;
  end   //Si elle est plus grande, alors il faut décrémenter.
  else if vitesse > 0 then
  begin
    vitesse:= vitesse - 1;
  end;
  result:=vitesse;
end;

procedure TPlayerObject.DeplacementDroit(player:integer);
begin
  players[player].xp_speed:=players[player].xp_speed + DEPLACEMENT;
  //Si on est dans la séquence de réparation, alors on as une petite animation de déplacement.
  if Self.confirmedDestruction then
    players[player].image.Picture.LoadFromFile('./ressources/players/pilot' + intToStr(player+1) + '_right.bmp');
end;

procedure TPlayerObject.DeplacementGauche(player:integer);
begin
  players[player].xp_speed:=players[player].xp_speed - DEPLACEMENT;

  if Self.confirmedDestruction then
    players[player].image.Picture.LoadFromFile('./ressources/players/pilot' + intToStr(player+1) + '_left.bmp');
end;

procedure TPlayerObject.DeplacementAvant(player:integer);
begin
  players[player].yp_speed:=players[player].yp_speed - DEPLACEMENT;
  if Self.confirmedDestruction then
    players[player].image.Picture.LoadFromFile('./ressources/players/pilot' + intToStr(player+1) + '_back.png');
end;

procedure TPlayerObject.DeplacementArriere(player:integer);
begin
  players[player].yp_speed:=players[player].yp_speed + DEPLACEMENT;
  if Self.confirmedDestruction then
    players[player].image.Picture.LoadFromFile('./ressources/players/pilot' + intToStr(player+1) + '_front.png');
end;

//Fonction getter qui récupère l'image.
function TPlayerObject.getImageAt(player:integer): TImage;
begin
  Result:= players[player].image;
end;

//Procédure qui set l'image.
procedure TPlayerObject.setImageAt(player: integer; picture: TImage);
begin
  players[player].image:= picture;
end;

//Fonction qui récupère la vie.
function TPlayerObject.getVieAt(player:integer): integer;
begin
  Result:= players[player].vie;
end;

//Procédure qui récupère la vie.
procedure TPlayerObject.setVieAt(player:integer; newVie:integer);
begin
  players[player].vie:= newVie;
end;

function TPlayerObject.getShootCoolDown(player:integer):integer;
begin
  result:= players[player].shootCoolDown;
end;

procedure TPlayerObject.setTempsDeTirAt(player:integer; newTempsDeTir:integer);
begin
  players[player].tempsDeTir:=newTempsDeTir;
end;

function TPlayerObject.getTempsDeTir(player:integer):integer;
begin
  result:= players[player].tempsDeTir;
end;

procedure TPlayerObject.setShootCoolDownAt(player:integer; newCoolDown:integer);
begin
  players[player].shootCoolDown:=newCoolDown;
end;

//Procédure qui ajoute un joueur.
procedure TPlayerObject.addPlayer(newPlayer: TPlayer);
begin
  //On change la taille du tableau.
  setLength(players, length(players) + 1);
  //On attribue le nouveau joueur à la dernière case du tableau.
  players[length(players)-1]:= newPlayer;
  //On incrémente le nombre de joueurs.
  Inc(self.nbJoueurs);
end;

end.


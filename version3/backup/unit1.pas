unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Windows, U_DynamicArray, U_Player;

type
  TSpaceshipSystem = Record
    image:TImage;
    damage:integer;
  end;

type

  { TDynamicShooter }

  TDynamicShooter = class(TForm)
    bottombar: TImage;
    background1: TImage;
    background2: TImage;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    pilot: TImage;
    InterieurVaisseau: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    TimerDestruction: TTimer;
    TimerAnimations: TTimer;
    TimerPrincipal: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure TimerAnimationsTimer(Sender: TObject);
    procedure TimerDestructionTimer(Sender: TObject);
    procedure TimerPrincipalTimer(Sender: TObject);
    //procedure DeplacementGauche(player:integer);   //}
    //procedure DeplacementDroit(player:integer);    //}
    //procedure DeplacementAvant(player:integer);    //}
    //procedure DeplacementArriere(player:integer);  //}
    procedure SpawnTir(path: string; location: integer; player:integer);      //fait apparaitre le premier type tir.
    procedure defileFond(firstBackground:TImage; secondBackground:TImage);
    procedure SpawnEnnemi(path: string; vie: integer);
    procedure collider(ennemi:TDynamicArray; Tir:TDynamicArray);
    //function inertie(vitesse:integer): integer;                            //}
    //function max_speed(vitesse:integer; speed:integer) : integer;          //}
    function Collide(ennemi: TImage; tir: TImage) : boolean;
    procedure EnDehors(tirOuEnnemi: TDynamicArray; genre:string);
    procedure move(vitesse: integer; elementMoved: TDynamicArray; vitesseX: integer);
    procedure spawnTirEnnemi(path: string; tirEnnemi:integer);
    //function CreatePlayer() : TPlayer;                                   //}
    procedure PlayerCollide(tirOuEnnemi:TDynamicArray; j:integer);       //}
    function PlayerEnnemiCollide(Ennemi:TDynamicArray; Joueur:TPlayerObject; index:integer): boolean;
    procedure CreateDestruction();
    function CreateSpaceshipSystem(index:integer): TSpaceshipSystem;
    function PilotCollision(PlayerPilot:TImage; system:TSpaceShipSystem): boolean;
    procedure createPlayerObject();
  private
  public
  end;

const
  VITESSE_TIRS = -15;
  VITESSE_ENNEMIS = 2;
  //0 équivaut à un joueur (fonctionnement des tableaux), mettre à 1 pour un deuxième joueur.
  //Mettre à un que à la fin de la programmation, pour éviter de devoir modifier le code pour les deux sans arrêt.
  MAX_PLAYERS = 0;
  //+1 au systèmes, propriété des tableaux.
  MAX_SYSTEMS = 3;
  JOUEUR_1 = 0;
  JOUEUR_2 = 1;
  NO_TRANSLATION = 0;
  TRANSLATION = 1;
  PATH_TIR_1 = 'tir1.bmp';
  PATH_TIR_2 = 'tir2.bmp';
  PATH_TIR_3 = 'tir3.bmp';
  PATH_TIRENNEMI_1 = 'tirEnnemi1.bmp';
  PATH_TIRENNEMI_2 = 'tirEnnemi2.bmp';
  PATH_TIRENNEMI_3 = 'tirEnnemi3.bmp';
  PATH_ENNEMI_1 = 'ennemis1.bmp';
  PATH_ENNEMI_2 = 'ennemis2.bmp';
  PATH_ENNEMI_3 = 'ennemis3.bmp';

var
  //déclarer les variables ici.
  DynamicShooter: TDynamicShooter;
  //pas de bornes, car c'est un tableau dynamique.
  //on déclare tirs comme appartenant à la classe TDynamicArray, classe qui contient les procédures et propriétés nécéssaires.
  tirs: TDynamicArray;
  ennemis: TDynamicArray;
  tirsEnnemi: TDynamicArray;
  test: TDynamicArray;
  shootCoolDown, tempsDeTir, EnnemiCoolDown, tempsDeTirEnnemi:integer;
  tempsEnnemi, attenteEnnemi:integer;
  hits: integer;
  vitesseFond: integer;
  inertie: integer;
  joueurs: TPlayerObject;
  //players: array[0..MAX_PLAYERS] of TPlayer;
  SpaceShipSystem: array[0..MAX_SYSTEMS] of TSpaceShipSystem;
  destruction: integer;
  count:integer;
  firstStage,secondStage, thirdStage: boolean;
  direction: integer;
  endStage : boolean;
  confirmDestruction: boolean;

implementation

{$R *.lfm}

{ TDynamicShooter }
//Fonction pour créer un joueur, que l'on attribue ensuite à un tableau dans le OnCreate.
{function TDynamicShooter.CreatePlayer() : TPlayer;
var
  newPlayer:TPlayer;
begin
  newPlayer.image:=TImage.create(DynamicShooter);
  newPlayer.image.parent:=DynamicShooter;
  newPlayer.image.picture.loadfromfile('./ressources/player.bmp');
  newPlayer.image.stretch:=true;
  newPlayer.image.transparent:=true;
  newPlayer.image.width:=100;
  newPlayer.image.height:=100;
  newPlayer.image.visible:=true;
  newPlayer.image.top:=DynamicShooter.height div 2 - newPlayer.image.height div 2;
  newPlayer.image.left:=DynamicShooter.width div 2 - newPlayer.image.width div 2;
  newPlayer.vie:=100;
  Result:=newPlayer;
end;}

procedure TDynamicShooter.createPlayerObject();
var newPlayer:TPlayer;
begin
  newPlayer.image:=TImage.create(DynamicShooter);
  newPlayer.image.parent:=DynamicShooter;
  newPlayer.image.picture.loadfromfile('./ressources/player.bmp');
  newPlayer.image.stretch:=true;
  newPlayer.image.transparent:=true;
  newPlayer.image.width:=100;
  newPlayer.image.height:=100;
  newPlayer.image.visible:=true;
  newPlayer.xp_speed:=0;
  newPlayer.yp_speed:=0;
  newPlayer.image.top:=DynamicShooter.height div 2 - newPlayer.image.height div 2;
  newPlayer.image.left:=DynamicShooter.width div 2 - newPlayer.image.width div 2;
  newPlayer.vie:=100;
  joueurs.addPlayer(newPlayer);
end;

//On passe un chemin d'accès et une position en paramètre, ainsi nous avons un tableau de tirs pour les trois tirs.
procedure TDynamicShooter.SpawnTir(path: string; location:integer; player:integer); //J'appelle cette procédure quand j'appuie sur espace.
var nouveauTir:TVaisseaux;
begin
  nouveauTir.image:= TImage.Create(self);  //Je crée un lien entre nouveau tir et une image.
  nouveauTir.image.Parent:= self;          //Je lui assigne lui même en tant que parent.

  //Propriétés de l'image.
  nouveauTir.image.picture.loadfromfile('./ressources/' + path);
  nouveauTir.image.stretch:=true;
  nouveauTir.image.width:=14;
  nouveauTir.image.height:=30;
  nouveauTir.image.visible:=true;
  nouveauTir.image.transparent:=true;

  nouveauTir.image.top:=joueurs.getImageAt(player).top;
  nouveauTir.image.left:=joueurs.getImageAt(player).left + location;

  tirs.AddElement(nouveauTir); //je rajoute un élément au tableau dynamique.
end;

procedure TDynamicShooter.SpawnEnnemi(path: string; vie: integer);
var nouveauEnnemi:TVaisseaux;
begin
  nouveauEnnemi.image:=TImage.Create(self);
  nouveauEnnemi.image.parent:=self;

  nouveauEnnemi.image.picture.LoadFromFile('./ressources/' + path);
  nouveauEnnemi.image.stretch:=true;
  nouveauEnnemi.image.width:=50;
  nouveauEnnemi.image.height:=50;
  nouveauEnnemi.image.visible:=true;
  nouveauEnnemi.image.transparent:=true;

  nouveauEnnemi.image.top:= 0 - nouveauEnnemi.image.Height;
  nouveauEnnemi.image.left:= random(DynamicShooter.width - nouveauEnnemi.image.width);
  nouveauEnnemi.Vie:= vie; //On règle la vie du joueur.

  ennemis.AddElement(nouveauEnnemi);
end;

procedure TDynamicShooter.SpawnTirEnnemi(path: string; tirEnnemi:integer);
var nouveauTirEnnemi:TVaisseaux;
begin
  nouveauTirEnnemi.image:= TImage.Create(self);  //Je crée un lien entre nouveau tir et une image.
  nouveauTirEnnemi.image.Parent:= self;          //Je lui assigne lui même en tant que parent.

  //Propriétés de l'image.
  nouveauTirEnnemi.image.picture.loadfromfile('./ressources/' + path);
  nouveauTirEnnemi.image.stretch:=true;
  nouveauTirEnnemi.image.width:=14;
  nouveauTirEnnemi.image.height:=30;
  nouveauTirEnnemi.image.visible:=true;
  nouveauTirEnnemi.image.transparent:=true;
  nouveauTirEnnemi.Vie:=0;

  nouveauTirEnnemi.image.top:=ennemis.getImageAt(tirEnnemi).top;
  nouveauTirEnnemi.image.left:=ennemis.getImageAt(tirEnnemi).left;

  tirsEnnemi.AddElement(nouveauTirEnnemi); //je rajoute un élément au tableau dynamique.
end;

//procédure appelée lors de la création du form.
procedure TDynamicShooter.FormCreate(Sender: TObject);
var i:integer;
begin
  //On initialise les variables ici.
  confirmDestruction:=false;
  DoubleBuffered:=true;
  DynamicShooter.height:=700;
  DynamicShooter.width:=600;
  bottombar.height:=50;
  bottombar.width:=DynamicShooter.width;
  bottombar.top:=DynamicShooter.Height - bottombar.height;
  bottombar.left:=0;
  destruction:=0;

  //Délai entre chaque apparition d'ennemi.
  tempsEnnemi:=120;
  attenteEnnemi:=0;
  tempsDeTir:=15;
  EnnemiCoolDown:=0;
  tempsDeTirEnnemi:=40;
  vitesseFond:=1;

  //Réglage du fond d'écran.
  background1.width:=DynamicShooter.width;
  background1.height:=DynamicShooter.height;
  background1.left:=0;
  background1.top:=0;

  background2.width:=DynamicShooter.width;
  background2.height:=DynamicShooter.height;
  background2.left:=0;
  background2.top:=-DynamicShooter.height;

  //création des ArrayDynamique.
  tirs:= TDynamicArray.Create;
  ennemis:=TDynamicArray.Create;
  tirsEnnemi:=TDynamicArray.Create;
  test:=TDynamicArray.Create;

  //Je crée le premier objet.
  joueurs:=TPlayerObject.Create(bottombar);

  createPlayerObject();

  //Initialisation des stages.
  firstStage:=true;
  secondStage:=false;
  thirdStage:=false;

  //On assigne un joueur au tableau, si on a deux joueurs, cela en crée un automatiquement.
  {for i:=0 to MAX_PLAYERS do
  begin
    players[i]:=CreatePlayer();
    players[i].image.left:=DynamicShooter.width div 2 - players[i].image.width div 2;
  end;        }
end;

function TDynamicShooter.Collide(ennemi: TImage; tir: TImage) : boolean;
begin
  //Procédure de collision entre les tirs et les ennemis.
  if (tir.top <= ennemi.top + ennemi.height div 2) and
  (tir.left >= ennemi.left) and
  (tir.left <= ennemi.left + ennemi.width) and
  (tir.top >= ennemi.top) then
  begin
    result:=true;
  end
  else
  begin
    result:=false;
  end
end;

//Procédure de collision entre les tirs, les ennemis et les joueurs.
procedure TDynamicShooter.PlayerCollide(tirOuEnnemi:TDynamicArray;j:integer);
var i:integer;
begin
  //Procédure de collision entre les tirs ennemis et le joueur.
  if tirOuEnnemi.Size > 0 then
  begin
    for i:=0 to tirOuEnnemi.Size - 1 do
    begin
      if (tirOuEnnemi.getImageAt(i).top <= joueurs.getImageAt(j).top + joueurs.getImageAt(j).height div 2) and
      (tirOuEnnemi.getImageAt(i).left >= joueurs.getImageAt(j).left) and
      (tirOuEnnemi.getImageAt(i).left <= joueurs.getImageAt(j).left + joueurs.getImageAt(j).width) and
      (tirOuEnnemi.getImageAt(i).top >= joueurs.getImageAt(j).top) then
      begin
        if tirOuEnnemi.getImageAt(i).visible then
        begin
          //En cas de collision, je décrémente la vie.
          tirOuEnnemi.getImageAt(i).visible:=false;
          joueurs.setVieAt(j, joueurs.getVieAt(j)-1);
        end;
      end;
      {else
      begin
        //Rien ne se passe.
      end  }
    end;
  end;
end;

//Collisions de l'ennemi avec le joueur, (TDynamicArray et TPlayer)
function TDynamicShooter.PlayerEnnemiCollide(Ennemi:TDynamicArray; Joueur:TPlayerObject; index:integer): boolean;
var
  i:integer;
begin
  result:=false;
  for i:=0 to Ennemi.NumberElement - 1 do
  begin
    if (Ennemi.getImageAt(i).top <= Joueur.getImageAt(index).top + Joueur.getImageAt(index).height div 2) and
    (Ennemi.getImageAt(i).left >= Joueur.getImageAt(index).left) and
    (Ennemi.getImageAt(i).left <= Joueur.getImageAt(index).left + Joueur.getImageAt(index).width) and
    (Ennemi.getImageAt(i).top >= Joueur.getImageAt(index).top) then
    begin
      if Ennemi.getImageAt(i).visible then
      begin
        result:=true;
        ennemi.getImageAt(i).visible:= false;
      end
      else
      begin
        result:=false;
      end;
    end;
  end;
  PlayerEnnemiCollide:= result;
end;

//Procédure de déplacement.
procedure TDynamicShooter.move(vitesse: integer; elementMoved: TDynamicArray; vitesseX: integer);
var i:integer;
    tmpImage:TImage;
begin
  //direction:=0;
  for i:=0 to elementMoved.Size - 1 do
  begin
    tmpImage:= elementMoved.getImageAt(i); //On prends l'image à cette case.
    tmpImage.top:= tmpImage.top + vitesse; //On la déplace.

    label7.caption:=IntToStr(direction);

    //On donne un déplacement horizontal aux ennemis au deuxième stage.
    if secondStage then
    begin
      if direction < 1000 then
      begin
        tmpImage.left:= tmpImage.Left - vitesseX;
        direction:=direction + 1;
      end;
      if (direction > 1000) and (direction < 2000) then
      begin
        tmpImage.left:= tmpImage.Left + vitesseX;
        direction:=direction + 1;
      end;
      if direction > 2000 then
      begin
        direction:=0;
      end;
    end;

    //Déplacement du troisième stage.
    if thirdStage then
    begin
      if direction < 500 then
      begin
        tmpImage.left:= tmpImage.Left - 6*vitesseX;
        direction:=direction + 1;
      end;
      if (direction > 500) and (direction < 1000) then
      begin
        tmpImage.left:= tmpImage.Left + 6*vitesseX;
        direction:=direction + 1;
      end;
      if direction > 1000 then
      begin
        direction:=0;
      end;
    end;
    //On replace l'image.
    elementMoved.setImageAt(i, tmpImage);
  end;
end;

procedure TDynamicShooter.defileFond(firstBackground: TImage; secondBackground:TImage);
begin
  firstBackground.top:=firstBackground.top + vitesseFond;
  secondBackground.top:=secondBackground.top + vitesseFond;

  if firstBackground.top >= DynamicShooter.height then
     firstBackground.top:= -DynamicShooter.height;

  if secondBackground.top >= DynamicShooter.height then
     secondBackground.top:= -DynamicShooter.height;
end;

//On appele les procédures de déplacement pour le joueur approprié. (Tableau de joueurs pour faciliter le multijoueur.)
{procedure TDynamicShooter.DeplacementGauche(player:integer); //préciser TDynamicShooter. pour accéder aux objects sans devoir mettre DynamicShooter. ...
begin
  players[player].xp_speed:=players[player].xp_speed - 5;
end;

procedure TDynamicShooter.DeplacementDroit(player:integer);
begin
  players[player].xp_speed:=players[player].xp_speed + 5;
end;

procedure TDynamicShooter.DeplacementAvant(player:integer);
begin
  players[player].yp_speed:=players[player].yp_speed - 5;
end;

procedure TDynamicShooter.DeplacementArriere(player:integer);
begin
  players[player].yp_speed:=players[player].yp_speed + 5;
end;
                                                            }
procedure TDynamicShooter.TimerPrincipalTimer(Sender: TObject);
var i, texture:integer;
begin
  label11.caption := IntToStr(length(SpaceShipSystem));
{  for i:=0 to MAX_PLAYERS do
  begin
    players[i].image.left := players[i].image.left + players[i].xp_speed;
    players[i].image.top := players[i].image.top + players[i].yp_speed;

    //Collisions du joueur avec les murs.
    if(players[i].image.top + players[i].image.Height >= bottombar.top) then
      players[i].image.top := bottombar.top - players[i].image.height;

    if(players[i].image.left <= 0) then
       players[i].image.left := 0;

    if(players[i].image.left + players[i].image.width >= DynamicShooter.width) then
       players[i].image.left := DynamicShooter.width - players[i].image.width;

    if(players[i].image.top <= 0) then
       players[i].image.top := 0;

    //Collisions du joueur avec les tirs ennemis.

  end;      }
                         //Joueur 1.
  PlayerCollide(tirsEnnemi, 0);

  if PlayerEnnemiCollide(ennemis, joueurs, 0) then
    confirmDestruction:=true;

  if confirmDestruction then
  begin
    timerPrincipal.enabled:=false;
    timerAnimations.enabled:=false;

    //On configure l'arène d'invasion.
    CreateDestruction();
    TimerDestruction.enabled:=true;
  end;

  direction:=direction + 1;
  label5.caption:=IntToStr(joueurs.getVieAt(0));

  //Appel de la procédure pour faire défiler le fond.
  defileFond(background1, background2);

  //appel de procédure de déplacement pour les ennemis et les tirs.      l.
  move(VITESSE_ENNEMIS, ennemis, 1);
  move(VITESSE_TIRS, tirs, NO_TRANSLATION);
  //Procédures pour les tirs des ennemis.
  move(-VITESSE_TIRS, tirsEnnemi, NO_TRANSLATION);

  //Procédure de supression des ennemis lorsqu'ils sont en dehors du cadre.
  //Le string est un paramètre, car il faut une condition différente à chaque fois.
  EnDehors(ennemis, 'ennemi');
  //procédure de suppression des tirs lors de collision avec le cadre.
  EnDehors(tirsEnnemi, 'tirEnnemi');
  EnDehors(tirs, 'tirJoueur');

  //Collisions entre les tirs et les ennemis.
  collider(ennemis, tirs);

  //Appel de procédures pour faire apparaitre les tirs ennemis.
  EnnemiCoolDown:=EnnemiCoolDown + 1;
  if ennemiCoolDown >= tempsDeTirEnnemi then
  begin
    for i:=0 to ennemis.Size - 1 do
    begin
      if ennemis.getImageAt(i).visible then
      begin
        texture:= random(4);
        if texture = 1 then
        begin
          SpawnTirEnnemi(PATH_TIRENNEMI_1, i);
        end
        else if texture = 2 then
        begin
          SpawnTirEnnemi(PATH_TIRENNEMI_2, i);
        end
        else if texture = 3 then
        begin
          SpawnTirEnnemi(PATH_TIRENNEMI_3, i);
        end;
        ennemiCoolDown:=0;
      end;
    end;
  end;

  //Procédure de tir.
  //Si j'appuie sur espace, je tire.
  label1.caption:=intToStr(tirs.Size);
  shootCoolDown:=shootCoolDown + 1;
  if(GetKeyState(ord(VK_SPACE)) < 0) then
       if shootCoolDown >= tempsDeTir then
         begin
           for i:= 0 to MAX_PLAYERS do
           begin
             //On appelle SpawnTir avec la texture et la position appropriée.
             SpawnTir(PATH_TIR_1, joueurs.getImageAt(i).width div 2,0);
             SpawnTir(PATH_TIR_2, 0,0);
             SpawnTir(PATH_TIR_3, joueurs.getImageAt(i).width,0);
             shootCoolDown:=0;
           end;
         end;

  //procedure de spawn des ennemis.
  label3.caption:=intToStr(ennemis.Size);
  attenteEnnemi:=attenteEnnemi + 1;
  if(attenteEnnemi >= tempsEnnemi) then
    begin
         SpawnEnnemi(PATH_ENNEMI_1, 1);
         SpawnEnnemi(PATH_ENNEMI_2, 2);
         SpawnEnnemi(PATH_ENNEMI_3, 3);
         attenteEnnemi:=0;
    end;

  label8.caption:=intToStr(tirsEnnemi.Size);
end;

procedure TDynamicShooter.TimerAnimationsTimer(Sender: TObject);
var i:integer;
begin
  //On gère les mouvements ici, à cause de l'inertie du joueur.
  //Déplacements du premier joueur.
  {if(GetKeyState(ord('D')) < 0) then
     DeplacementDroit(JOUEUR_1);

  if(GetKeyState(ord('A')) < 0) then
     DeplacementGauche(JOUEUR_1);

  if(GetKeyState(ord('W')) < 0) then
     DeplacementAvant(JOUEUR_1);

  if(GetKeyState(ord('S')) < 0) then
     DeplacementArriere(JOUEUR_1);

  //Déplacements du deuxième joueur.
  if(GetKeyState(ord('L')) < 0) then
     DeplacementDroit(JOUEUR_2);

  if(GetKeyState(ord('J')) < 0) then
     DeplacementGauche(JOUEUR_2);

  if(GetKeyState(ord('I')) < 0) then
     DeplacementAvant(JOUEUR_2);

  if(GetKeyState(ord('K')) < 0) then
     DeplacementArriere(JOUEUR_2);  }

  //Si la vitesse est plus petite que zéro, alors il faut incrémenter.
 { for i:=0 to MAX_PLAYERS do
  begin
    players[i].yp_speed:=max_speed(players[i].yp_speed, 8);
    players[i].yp_speed:=inertie(players[i].yp_speed);

    players[i].xp_speed:=max_speed(players[i].xp_speed, 8);
    players[i].xp_speed:=inertie(players[i].xp_speed);
  end;                                                   }

  label12.caption:= IntToStr(joueurs.nbJoueurs);
  if joueurs.nbJoueurs = 1 then
  begin
    joueurs.movePlayer(0);
  end;
end;
{
function TDynamicShooter.Inertie(vitesse:integer) : integer;
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

//Ajouter +4 au paramètre souhaité pour avoir la vitesse souhaitée, à cause des timers la limite n'est pas respectée.
function TDynamicShooter.max_speed(vitesse:integer; speed:integer) : integer;
begin
  if vitesse < -speed then
    vitesse:= -speed;

  if vitesse > speed then
    vitesse:= speed;

  result:=vitesse;
end;
                                                                                          }
//procedure de collision entre les tirs et les ennemis.
procedure TDynamicShooter.collider(ennemi:TDynamicArray; Tir:TDynamicArray);
var j,i : integer;
begin
  if (Tir.Size > 0) and (ennemi.Size > 0) then
    begin
      for j:= 0 to ennemi.Size - 2 do
      begin
        for i:= 0 to Tir.Size - 1 do
        begin
          if Collide(ennemi.getImageAt(j), Tir.getImageAt(i)) then
          begin
            //Cela veut dire que la collision a lieu.
            //Si ils sont visibles,
            if (ennemi.getImageAt(j).visible) and (Tir.getImageAt(i).visible) then
            begin
                //Je les rends invisibles.
                ennemi.setVieAt(ennemi.getVieAt(j) - 1, j);
                Tir.getImageAt(i).visible:=false;
                //Si la vie de l'ennemi est négative, on le rends invisible.
                if ennemi.getVieAt(j) <= 0 then
                begin
                  ennemi.getImageAt(j).visible:=false;
                  break;
                end;
            end;
          end;      //Bug: Je ne peux pas remove Element directement sans causer des bugs, car je décale tout le tableau.
        end;        //Donc pour éviter cela je rends juste les images invisibles, et je ne détecte pas
      end;          //la collision si elles sont invisibles.
    end;
end;


//Procedure de collision de l'ennemi avec le sol.
procedure TDynamicShooter.EnDehors(tirOuEnnemi: TDynamicArray; genre:string);
var i:integer;
begin
  if tirOuEnnemi.Size > 0 then
  begin
    for i:=0 to tirOuEnnemi.NumberElement - 1 do
    begin
      if(genre = 'ennemi') and (tirOuEnnemi.getImageAt(i).top >= DynamicShooter.height) then
      begin
        tirOuEnnemi.RemoveElement(tirOuEnnemi.getImageAt(i));
        break; //break essentiel, sinon il ne peux plus getImageAt(i) ce qui provoque une erreur.
      end;

      if(genre = 'tirJoueur') and (tirOuEnnemi.getImageAt(i).top <= 0 - 2*tirOuEnnemi.getImageAt(i).height) then
      begin
        tirOuEnnemi.RemoveElement(tirOuEnnemi.getImageAt(i));
        break; //Break essentiel.
      end;

      if(genre = 'tirEnnemi') and (tirOuEnnemi.getImageAt(i).top >= DynamicShooter.Height) then
      begin
        tirOuEnnemi.RemoveElement(tirOuEnnemi.getImageAt(i));
        break;
      end;
    end;
  end;
end;

//Procédure de création de l'arène pour la séquence de réparation.
procedure TDynamicShooter.CreateDestruction();
var
  i,j,k,l:integer;
  invisible:TImage;
begin
  //On rends invisible tout ce qui ne nous intérèsse pas.
  joueurs.getImageAt(0).visible:=false;
  invisible:=joueurs.getImageAt(0);
  joueurs.setImageAt(0,invisible);
  for j:= 0 to ennemis.Size - 1 do
  begin
    ennemis.getImageAt(j).visible:=false;
  end;
  for k:=0 to tirsEnnemi.Size - 1 do
  begin
    tirsEnnemi.getImageAt(k).visible:=false;
  end;
  for l:=0 to tirs.Size - 1 do
  begin
    tirs.getImageAt(l).visible:=false;
  end;

  ennemis.destroyArray();
  tirs.destroyArray();
  tirsEnnemi.destroyArray();
  Randomize;

  //Configuration de l'arrière plan.
  InterieurVaisseau.visible:=true;
  InterieurVaisseau.height:=DynamicShooter.height;
  InterieurVaisseau.Width:=DynamicShooter.width;
  InterieurVaisseau.top:=0;
  InterieurVaisseau.left:=0;

  //Configuration du pilote.
  pilot.top:= DynamicShooter.height div 2 - pilot.height div 2;
  pilot.left:= DynamicShooter.width div 2 - pilot.width div 2;
  pilot.visible:= true;

  count:=0;     //Entre 0 et 3.
  destruction:= random(4);

  //J'assigne un spaceShipSystem à chaque case de mon tableau.
  for i:=0 to destruction do
  begin
    SpaceshipSystem[i]:= CreateSpaceshipSystem(i);
  end;

end;

//Fonction qui crée un Système de bord endomagé, qu'il faut ensuite réparer, le résultat
//est un TSpaceShipSystem.
function TDynamicShooter.CreateSpaceshipSystem(index:integer): TSpaceShipSystem;
var
  newSystem:TSpaceShipSystem;
  positionsX: array[0..3] of Integer = (20, 20, 400, 400);
  positionsY: array[0..3] of Integer = (100, 300, 100, 300);
  //index:integer;
begin
  newSystem.image:=TImage.create(DynamicShooter);  //On crée l'image.
  newSystem.image.parent:=DynamicShooter;          //On lui donne un parent.
  newSystem.image.Picture.loadFromFile('./ressources/destroyedSystem.bmp');
  Randomize;
  newSystem.damage:=random(200);     //Dégats.
  newSystem.image.Visible:=true;

  //Case du tableau aléatoire.
  newSystem.image.top:= positionsY[index];
  newSystem.image.left:= positionsX[index];
  Result:= newSystem;
end;

//C'est ici que l'on gère ce qui se passe dans la séquence de réparation.
procedure TDynamicShooter.TimerDestructionTimer(Sender: TObject);
var i:integer;
begin
    //Déplacement du pilote.
    if(GetKeyState(ord('D')) < 0) then
       pilot.left:= pilot.left + 5;

    if(GetKeyState(ord('A')) < 0) then
       pilot.left:= pilot.left - 5;

    if(GetKeyState(ord('W')) < 0) then
       pilot.top:= pilot.top -5;

    if(GetKeyState(ord('S')) < 0) then
       pilot.Top:= pilot.top + 5;

    //Collisions entre le pilote et les systèmes de bord.
    for i:=0 to destruction do
    begin
      if PilotCollision(pilot, SpaceShipSystem[i]) and (GetKeyState(VK_SPACE) < 0) then
      begin
        //Réparation du système.
        SpaceShipSystem[i].damage:= SpaceShipSystem[i].damage - 1;
        count:=count + 1;
        if SpaceShipSystem[i].damage <= 0 then
        begin
          SpaceShipSystem[i].image.visible:= false;
        end;
      end;

      //Si tous les systèmes sont réparés, fin de la séquence.
      if SpaceShipSystem[i].image.visible = false then
      begin
        label10.caption:='Fin de la réparation';
      end;
    end;
end;

//Collisions entre le pilote et les systèmes.
function TDynamicShooter.PilotCollision(PlayerPilot:TImage; system:TSpaceShipSystem): boolean;
begin
      if (system.image.top <= PlayerPilot.top) and
      (system.image.top + system.image.height >= PlayerPilot.top + PlayerPilot.height) and
      (system.image.left <= PlayerPilot.left) and
      (system.image.left + system.image.width >= PlayerPilot.left) then
      begin
       Result:=True;
      end
      else
      begin
        Result:=False;
      end;
end;

end.













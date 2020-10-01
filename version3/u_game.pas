{***************************************************************
 * Description : Dynamic Shooter game main form.               *
 * Author      : Arthur Freeman                                *
 * Date        : 10.22.2018                                    *
 * Version     : 8.1.                                          *
 ***************************************************************}
unit U_Game;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Windows, U_DynamicArray, U_Player, math, MMSystem; //Pour que les gifs fonctionnent il faut impérativement
                                                                      //déclarer cet unit, sinon TOUT foire.
//Déclarationd de types.
type

  //Record, on s'en sert pour les lasers du boss,
  TSpaceshipSystem = Record //ainsi que pour les systèmes à réparer.
    image:TImage;
    damage:integer;
    v_x:integer;
  end;

  TBoss = Record //Boss.
    vaisseau:TImage;
    vie:integer;
    bossLaserCoolDown:integer;
    lasers:array[0..1] of TSpaceShipSystem;
    mines:array[0..30] of TMines; //Array de TMines, qui est un record définit dans U_Player.
    TirCoolDown:integer;
    activeMines:boolean;
    mineCoolDown:integer;
    bossCount:integer; //Variable du 'score' du boss, on s'en sert pour régler
  end;

  TScore = Record // Crée une structure pour l'enregistrement des scores
    pseudo : string[50]; // Pseudo du joueur
    score : integer; // Score du joueur
  end;

  { TDynamicShooter }

  TDynamicShooter = class(TForm)
    PlayButton,stage1Button,stage2Button,stage3Button,bossButton:TLabel;
    TimerDestruction: TTimer;
    TimerPrincipal: TTimer;
    TimerDialogue: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure TimerDestructionTimer(Sender: TObject);
    procedure TimerPrincipalTimer(Sender: TObject);
    procedure SpawnTir(path: string; index:integer; genre: string);      //fait apparaitre le premier type tir.
    procedure Shoot(player:integer);
    procedure defileFond(firstBackground:TImage; secondBackground:TImage; vitesse:integer);
    procedure SpawnEnnemi(path: string; vie: integer; vitesse_y:integer);
    procedure EnDehors(tirOuEnnemi: TDynamicArray; genre:string);
    procedure move(elementMoved: TDynamicArray; genre:string);
    procedure CreateDestruction();
    procedure createPlayerObject();
    procedure createBoss();
    procedure collisions(); //Procédure qui contient les algorithmes de collision.
    procedure menuPrincipal();
    procedure stageSelection();
    procedure Start();
    procedure stageLabelClick(Sender:TObject);
    procedure stage1ButtonClick(Sender:TObject);
    procedure stage2ButtonClick(Sender:TObject);
    procedure stage3ButtonClick(Sender:TObject);
    procedure TimerDialogueTimer(Sender:TObject);
    procedure bossButtonClick(Sender:TObject);
    procedure freePlayLabelClick(Sender:TObject);
    procedure backLabelClick(Sender:TObject);
    procedure playButtonClick(Sender:TObject);
    procedure player1LabelClick(Sender:TObject);
    procedure player2LabelClick(Sender:TObject);
    procedure store(Sender:TObject);
    procedure labelDeclareWarOnClick(Sender:TObject);
    procedure labelPeaceOnClick(Sender:TObject);
    procedure backToGameButtonClick(Sender:TObject);
    procedure EmptyScreen();
    procedure reduceTempsDeTir(Sender:TObject);
    procedure upgradeTirs(Sender:TObject);
    procedure repairShip(Sender:TObject);
    procedure controlsLabelClick(Sender:TObject);
    procedure creditsLabelClick(Sender:TObject);
    procedure enterButtonClick(Sender:TObject);
    procedure exit(Sender:TObject);
    procedure SaveScore();   //Procédures qui gèrent le score. Ont étés écrites en 2017
    procedure ChargerScore();//par Alan Devaud.
    procedure DisplayScore();//Ces trois procédures ne sont pas les miennes, elles sont d'un ancien projet.
    function Collide(ennemi: TImage; tir: TImage) : boolean; //Condition de collision.
    function CreateSpaceshipSystem(positionnement:integer; degats:integer): TSpaceshipSystem;
    function createLabel(texte:string;x:integer;y:integer):TLabel;
    function createImage(path:string;largeur:integer;hauteur:integer;visibleOrNot:boolean;x:integer;y:integer):TImage;
  private
  public
  end;

const
  VITESSE_TIRS = -15; VITESSE_ENNEMIS = 2; MAX_SYSTEMS = 5; //Nombre d'ordinateurs à réparer
  JOUEUR_1 = 0; JOUEUR_2 = 1; NO_TRANSLATION = 0;           //dans la séquence de réparation
  RES = './ressources/';
  FICHIER_SCORE = RES + 'scoreboard/scores.dat';  //Localisation du fichier qui contient les scores.
  INTERIEUR_VAISSEAU = RES + '/background/interieurVaisseau.bmp';  //On mets les paths des textures dans des constantes, c'est plus propre.
  BACKGROUND1_PATH = RES + 'background/background1.bmp';
  BACKGROUND2_PATH = RES + 'background/background2.bmp';
  BOTTOMBAR_PATH = RES + 'background/bottombar.bmp';
  SHIELD_PATH = RES + 'powers/shield/shield1.bmp';
  SHIELD_PATH_2 = RES + 'powers/shield/shield2.bmp';
  BOSS_PATH = RES + 'boss/boss.bmp';
  BOSSLASER_PATH = RES + 'boss/lasers.bmp';
  PATH_TIR_BOSS = RES + 'boss/tirBoss1.bmp';
  LASER_PATH = RES + 'powers/laser/laser.bmp';
  TITLE_PATH = RES + 'menus/title.png';
  PLAYER_MINE = RES + 'powers/mines/mine.bmp';
  BOSSMINES_PATH = RES + 'boss/bossMine.bmp';
  PLAYER_PATH = RES + 'players/player.bmp';
  PATH_TIR_1 = RES + 'players/tir1.bmp';
  PATH_TIR_2 = RES + 'players/tir2.bmp';
  PATH_TIR_3 = RES + 'players/tir3.bmp';
  PATH_TIRENNEMI_1 = RES + 'ennemis/tirs/tirEnnemi1.bmp';
  PATH_TIRENNEMI_2 = RES + 'ennemis/tirs/tirEnnemi2.bmp';
  PATH_TIRENNEMI_3 = RES + 'ennemis/tirs/tirEnnemi3.bmp';
  PATH_ENNEMI_1 = RES + 'ennemis/vaisseau/ennemis1.bmp';
  PATH_ENNEMI_2 = RES + 'ennemis/vaisseau/ennemis2.bmp';
  PATH_ENNEMI_3 = RES + 'ennemis/vaisseau/ennemis3.bmp';
  PATH_TERMINAL_1 = RES + 'terminals/fixedSystem.bmp';
  PATH_TERMINAL_2 = RES + 'terminals/destroyedSystem.bmp';
  REPLIQUES_PATH = RES + 'dialogue/repliques.txt';

var
  //Déclarer les variables ici.
  DynamicShooter:TDynamicShooter; //Instance du form.
  background1,background2,InterieurVaisseau,title,controlsImage,piccard:TImage;   //pas de bornes, car c'est un tableau dynamique.
  tirsJoueur,ennemis,tirsEnnemi,tirsBoss:TDynamicArray; //on déclare tirsJoueur comme appartenant à la classe TDynamicArray, classe qui contient les procédures et propriétés nécéssaires.
  joueurs:TPlayerObject; //Instance de la classe TPlayerObject.
  boss:TBoss; //Instance du Record TBoss.
  SpaceShipSystem:array of TSpaceShipSystem; //Tableau dynamique d'ordinateurs.
  scores:array[0..9] of TScore; //Tableau contenant la liste de scores du scoreboard.
  scoreboard:TMemo; //Variable scoreboard, instance de la classe TMemo.
  textBox:TEdit; //Boîte pour insérer le nom.
  pseudo:string;
  enterButton:TButton;
  repliques:TStringList;
  tempsDeTir,EnnemiCoolDown,tempsDeTirEnnemi,tempsEnnemi,attenteEnnemi:integer;
  vitesseFond,ennemiSpeed1,ennemiSpeed2,ennemiSpeed3,degats,replique:integer;
  destruction,timeLimit,initialTimeLimit,decalage,wait,music: integer;
  score,bossCoolDown,bossCounter,nbRepaired,credits,reduceTirCoolDownPrice,n:integer;
  firstStage,secondStage,thirdStage,bossStage,freePlay,confirmDestruction,isInMenus,hasReturned,characterHasBeenLoaded:boolean;
  systemsRepaired,dead,hasDeclaredWar,peace,hasBeenKilled,playersLose,canChange,hasClickedBack:boolean;
  nbMines,nbInitialJoueurs,nbTirs,newTirPrice,repairCost,bottomDecalage:integer;
  labelUpgradeTirs,labelUpgradeTempsDeTir,labelBackToGame,labelStore:TLabel;
  labelBoss,labelCountDown,labelCredits,labelControls,labelCreditsMenu: TLabel;
  stageLabel,labelDialogue,backLabel,labelScore,labelVieJ1,labelVieJ2:TLabel;
  player1Label,player2Label,labelExit,labelFullRepair,freePlayLabel:TLabel;
  labelDeclareWar,labelPeace,dialogueBox: TLabel;
implementation

{$R *.lfm}

{ TDynamicShooter }

//Fonction qui crée un label sur le form, évite le copier collé.
function TDynamicShooter.createLabel(texte:string;x:integer;y:integer):TLabel;
var
  newLabel:TLabel;
begin
  newLabel:=TLabel.Create(self);
  newLabel.parent:=self;
  newLabel.Caption:=texte;
  newLabel.Font.Name:='Fugaz One';
  newLabel.Font.Style:=[Graphics.fsBold];
  newLabel.Font.Size:=20;
  newLabel.Font.Color:=clwhite;
  newLabel.Left:=x;
  newLabel.top:=y;
  Result:=newLabel;
end;

//Fonction qui crée des images, beaucoup de paramètres, mais évite le copié collé...
function TDynamicShooter.createImage(path:string;largeur:integer;hauteur:integer;visibleOrNot:boolean;x:integer;y:integer):TImage;
var
  newImage:TImage;
begin
  newImage:=TImage.create(self);
  newImage.parent:=self;
  newImage.stretch:=true;
  newImage.picture.LoadFromFile(path);
  newImage.width:=largeur;
  newImage.height:=hauteur;
  newImage.visible:=visibleOrNot;
  newImage.left:=x;
  newImage.top:=y;
  Result:=newImage;
end;

//procédure appelée lors de la création du form.
procedure TDynamicShooter.FormCreate(Sender: TObject);
begin
  DynamicShooter.BorderStyle:=bsSingle;
  isInMenus:=true;
  n:=0;
  music:=550;
  canChange:=false;
  //DoubleBuffered:=true;
  hasDeclaredWar:=false;
  replique:=0;
  wait:=0;
  bottomDecalage:=45;
  hasBeenKilled:=false;
  repliques:=TStringList.Create;
  repliques.LoadFromFile(REPLIQUES_PATH);
  pseudo:='Enter name before starting';
  characterHasBeenLoaded:=false;

  //On crée tous les objets dynamiquement, le form est vide!
  TimerDestruction:= TTimer.Create(self);
  TimerDestruction.Interval:=15;
  TimerDestruction.onTimer:=@TimerDestructionTimer;
  TimerDestruction.enabled:=false;

  TimerPrincipal:= TTimer.Create(self);
  TimerPrincipal.Interval:=10;
  TimerPrincipal.onTimer:=@TimerPrincipalTimer;
  TimerPrincipal.enabled:=false;

  TimerDialogue:= TTImer.Create(self);
  TimerDialogue.Interval:=50;
  TimerDialogue.onTimer:=@TimerDialogueTimer;
  TimerDialogue.enabled:=false;

  DynamicShooter.height:=800;
  DynamicShooter.width:=600;  //Configuration de l'icone de la fenêtre.
  DynamicShooter.icon.LoadFromFile('./ressources/icon/official_icon.ico');
  decalage:=50;
  TimerPrincipal.Enabled:=false;
  nbInitialJoueurs:=0;
  ennemiCoolDown:=0;
  freePlay:=false;

  //Réglage du fond d'écran.
  background1:=createImage(BACKGROUND1_PATH, DynamicShooter.Width, DynamicShooter.height, true, 0, 0);
  background2:=createImage(BACKGROUND2_PATH, DynamicShooter.width, DynamicShooter.height, true, 0, -DynamicShooter.height);

  //Initialisation des images du form.
  bottombar:=createImage(BOTTOMBAR_PATH, DynamicShooter.width, 50, false, 0, DynamicShooter.height - decalage);
  title:=createImage(TITLE_PATH, 600, 800, true, 0, 0);
  title.transparent:=false;
  InterieurVaisseau:=createImage(INTERIEUR_VAISSEAU, DynamicShooter.width, DynamicShooter.height, false, 0, 0);

  //Initialisation des bouttons.  (Ce sont des labels)
  playButton:=createLabel('Play', 52, 440);
  playButton.Font.Size:=35;
  playButton.OnClick:=@playButtonClick;

  //Labels de sélection de joueurs.
  player1Label:=createLabel('1 Player', 44, 500);
  player1Label.visible:=true;
  player1Label.Font.color:=clGreen;
  player1Label.OnClick:=@player1LabelClick;

  //Labels de sélection de joueurs.
  player2Label:=createLabel('2 Players', 40, 535);
  player2Label.visible:=true;
  player2Label.OnClick:=@player2LabelClick;

  stageLabel:=createLabel('Stage selection', 35, 568);
  stageLabel.OnClick:=@stageLabelClick;

  labelControls:=createLabel('Controls', 30, 600);
  labelControls.OnClick:=@controlsLabelClick;

  labelCreditsMenu:=createLabel('Credits', 25, 630);
  labelCreditsMenu.OnClick:=@creditsLabelClick;

  labelExit:=createLabel('Exit', 20, 660);
  labelExit.OnClick:=@Exit;

  stage1Button:=createLabel('Stage 1', 50, 470);
  stage1Button.OnClick:=@stage1ButtonClick;

  stage2Button:=createLabel('Stage 2', 44, 500);
  stage2Button.OnClick:=@stage2ButtonClick;

  stage3Button:=createLabel('Stage 3', 40, 535);
  stage3Button.OnClick:=@stage3ButtonClick;

  bossButton:=createLabel('Boss', 35, 568);
  bossButton.OnClick:=@bossButtonClick;

  freePlayLabel:=createLabel('Free play', 30, 600);
  freePlayLabel.visible:=false;
  freePlayLabel.OnClick:=@freePlayLabelClick;

  backLabel:=createLabel('Back', 25, 630);
  backLabel.Font.Style:=[fsBold];
  backLabel.visible:=false;
  backLabel.OnClick:=@backLabelClick;

  labelScore:=createLabel('', 350, DynamicShooter.height - bottomDecalage);
  labelScore.Font.Name:='Raleway';
  labelScore.visible:=false;

  labelStore:=createLabel('Store', DynamicShooter.width div 2  - 25, DynamicShooter.height - bottomDecalage);
  labelStore.Left:=DynamicShooter.width div 2 - labelStore.width div 2;
  labelStore.Font.Name:='Raleway';
  labelStore.OnClick:=@store;

  labelBackToGame:=createLabel('Back To Game', DynamicShooter.width - decalage*4, DynamicShooter.height - decalage);
  labelBackToGame.visible:=false;
  labelBackToGame.OnClick:=@backToGameButtonClick;

  labelUpgradeTirs:=createLabel('Add a laser (cost:' + intToStr(newTirPrice) + ')', DynamicShooter.width div 4, DynamicShooter.height div 2);
  labelUpgradeTirs.visible:=false;
  labelUpgradeTirs.OnClick:=@upgradeTirs;

  labelUpgradeTempsDeTir:=createLabel('Reduce laser cooldown (cost:' + intToStr(reduceTirCoolDownPrice) + ')', DynamicShooter.width div 4, DynamicShooter.height div 2 + decalage);
  labelUpgradeTempsDeTir.visible:=false;
  labelUpgradeTempsDeTir.OnClick:=@reduceTempsDeTir;

  labelFullRepair:=createLabel('Repair ship (cost:' + intToStr(repairCost) + ')', DynamicShooter.width div 4, DynamicShooter.height div 2 + decalage*2);
  labelFullRepair.visible:=false;
  labelFullRepair.OnClick:=@repairShip;

  labelCountDown:=createLabel(intToStr(timeLimit), DynamicShooter.width div 2, DynamicShooter.height div 2);
  labelCountDown.visible:=false;
  labelCountDown.AutoSize:=false;
  labelCountDown.width:=300;

  labelVieJ1:=createLabel('', bottombar.left, DynamicShooter.height - bottomDecalage);
  labelVieJ1.Font.Name:='Raleway';
  labelVieJ1.visible:=false;

  labelVieJ2:=createLabel('', bottombar.width - 110, DynamicShooter.height - bottomDecalage);
  labelVieJ2.Font.Name:='Raleway';
  labelVieJ2.visible:=false;

  labelDeclareWar:=createLabel('Declare War',DynamicShooter.width div 2, DynamicShooter.height div 2);
  labelDeclareWar.visible:=false;
  labelDeclareWar.OnClick:=@labelDeclareWarOnClick;

  labelPeace:=createLabel('Leave',DynamicShooter.width div 2, DynamicShooter.height div 2 + decalage*2);
  labelPeace.visible:=false;
  labelPeace.OnClick:=@labelPeaceOnClick;

  labelDialogue:=createLabel('', 52, 0);
  labelDialogue.AutoSize:=false;
  labelDialogue.width:=0;
  labelDialogue.height:=25;
  labelDialogue.visible:=true;
  labelDialogue.Font.Size:=15;

  controlsImage:=createImage('./ressources/menus/controls.png', 600, 800, false, 0, 0);
  piccard:=createImage('./ressources/dialogue/static.bmp', 50, 50, false, 0, 0);

  //Label de vie du boss.
  labelBoss:=createLabel('labelBoss', DynamicShooter.width div 2, decalage + 10);

  labelBoss.height:=50;
  labelBoss.width:=120;
  labelBoss.Font.Color:=clWhite;
  labelBoss.Font.Size:=35;
  labelBoss.visible:=false;

  labelCredits:=createLabel('Credits:', 120, DynamicShooter.height - bottomDecalage);
  labelCredits.Font.Name:='Raleway';
  labelCredits.visible:=false;

  //Configuration des tableaux et boites de dialogue de score.
  scoreboard:=TMemo.Create(self);
  scoreboard.Parent:=self;
  scoreboard.Enabled:=false;
  scoreboard.ReadOnly:=true;
  scoreboard.Color:=clblack;
  scoreboard.Font.Name:='Fugaz One';
  scoreboard.Font.Size:=10;
  scoreboard.Font.Color:=clwhite;
  scoreboard.Top:=335;
  scoreboard.left:=55;
  scoreboard.Font.Bold:=true;
  scoreboard.height:=100;
  scoreboard.width:=260;
  ChargerScore();
  DisplayScore();

  textBox:=TEdit.Create(self);
  textBox.Parent:=self;
  textBox.Color:=clblack;
  textBox.Font.Name:='Fugaz One';
  textBox.Font.Color:=clwhite;
  textBox.Caption:='Enter name before starting.';
  textBox.Width:=scoreBoard.width - 100;
  textBox.top:=scoreboard.top - textbox.height - 5;
  textBox.left:=scoreboard.left;
  textBox.Font.Size:=8;
  textBox.AutoSize:=false;
  firstStage:=true;
  canChange:=false;

  enterButton:=TButton.Create(self);
  enterButton.Parent:=self;
  enterButton.width:=100;
  enterButton.Font.Name:='Fugaz One';
  enterButton.Font.Color:=clWhite;
  enterButton.Color:=clBlack;
  enterButton.Left:=textBox.left + textbox.width;
  enterButton.Top:=textbox.top;
  enterButton.Height:=textBox.height;
  enterButton.Caption:='Enter Name';
  enterButton.OnClick:=@enterButtonClick;
  menuPrincipal(); //On appele la procédure qui affiche le menu principal.
end;

procedure TDynamicShooter.enterButtonClick(Sender:TObject);
begin
  pseudo:=textBox.text;
  textBox.Caption:='';
end;

//Procédure quand j'appuie sur controles.
procedure TDynamicShooter.controlsLabelClick(Sender:TObject);
begin
  labelControls.visible:=false;
  PlayButton.visible:=false;
  player1Label.visible:=false;
  player2Label.visible:=false;
  stageLabel.visible:=false;
  labelExit.visible:=false;
  backLabel.Top:=725;
  backLabel.Left:=45;
  backLabel.visible:=true;
  controlsImage.Visible:=true;
  backLabel.BringToFront;
  textBox.Visible:=false;
  scoreboard.visible:=false;
  enterButton.visible:=false;
end;
//Procédure quand j'appuie sur play.
procedure TDynamicShooter.playButtonClick(Sender:TObject);
begin
  labelCreditsMenu.visible:=false;
  enterButton.visible:=false;
  textBox.visible:=false;
  timerDialogue.enabled:=true;
  piccard.visible:=true;
  labelDialogue.visible:=true;
  replique:=0;
  labelDialogue.width:=0;
  bossStage:=false;
  firstStage:=false;
  secondStage:=false;
  thirdStage:=false;
  score:=0;
  freePlayLabel.visible:=false;
  labelControls.visible:=false;
  labelExit.visible:=false;
  scoreboard.visible:=false;
  title.visible:=false;
  PlayButton.visible:=false;
  stageLabel.visible:=false;
  stage1Button.visible:=false;
  stage2Button.visible:=false;
  stage3Button.visible:=false;
  player1Label.visible:=false;
  player2Label.visible:=false;
  bossButton.visible:=false;
  backLabel.visible:=false;
  canChange:=false;
  replique:=0;
end;

procedure TDynamicShooter.creditsLabelClick(Sender:TObject);
begin
  PlayButton.visible:=false;
  backLabel.visible:=true;
  stageLabel.visible:=false;
  player1Label.visible:=false;
  player2Label.visible:=false;
  labelExit.visible:=false;
  labelControls.visible:=false;
  labelCreditsMenu.Top:=PlayButton.top;
  labelCreditsMenu.Font.Size:=12;
  labelCreditsMenu.Caption:='     Programming by Arthur Freeman' + #13#10 + '    -''Still can''t beat the boss''' + #13#10 + '   Music by Daan Engelbarts' +  #13#10 + '  -''music is a language of it''s own''' + #13#10 + ' Graphics by Sébastien Bargetzi' + #13#10 + '-¯\_(ツ)_/¯';
end;

//Procédure quand j'appuie sur  1 joueur.
procedure TDynamicShooter.player1LabelClick(Sender:TObject);
begin
  player1Label.Font.color:=clGreen;
  player2Label.Font.color:=clNone;
  nbInitialJoueurs:=0;
end;
procedure TDynamicShooter.player2LabelClick(Sender:TObject);
begin
  player2Label.Font.color:=clGreen;
  player1Label.Font.color:=clNone;
  nbInitialJoueurs:=1;  //nbInitialJoueurs est le nombre initial de joueurs. 0 pour 1 et 1 pour 2.
end;                    //(Tableau de 0..1)
                              //Case: 1, 2
//On appelle la procédure stage selection pour afficher le menu des stages.
procedure TDynamicShooter.stageLabelClick(Sender:TObject);
begin
  backLabel.left:=25;
  backLabel.Top:=630;
  stageSelection();
end;
procedure TDynamicShooter.stage1ButtonClick(Sender:TObject);
begin
  secondStage:=false;
  thirdStage:=false;
  bossStage:=false;
  firstStage:=true;
  Start();
end;

procedure TDynamicShooter.stage2ButtonClick(Sender:TObject);
begin
  firstStage:=false;
  thirdStage:=false;
  bossStage:=false;
  secondStage:=true;
  Start();
end;

procedure TDynamicShooter.stage3ButtonClick(Sender:TObject);
begin
  firstStage:=false;
  secondStage:=false;
  bossStage:=false;
  thirdStage:=true;
  Start();
end;

procedure TDynamicShooter.bossButtonClick(Sender:TObject);
begin
  firstStage:=false;
  secondStage:=false;
  thirdStage:=false;
  bossStage:=true;        //On initialise le stage.
  Start();
end;

procedure TDynamicShooter.freePlayLabelClick(Sender:TObject);
begin
  firstStage:=false;
  secondStage:=false;
  thirdStage:=false;
  bossStage:=false;
  freePlay:=true;
  Start();
end;

procedure TDynamicShooter.backLabelClick(Sender:TObject);
begin
  isInMenus:=false;
  hasClickedBack:=true;
  menuPrincipal();
end;

procedure TDynamicShooter.exit(Sender:TObject);
begin
  application.terminate;  //On supprime le processus...
end;

procedure TDynamicShooter.menuPrincipal();
begin

  if not hasClickedBack then
  begin
    SaveScore(); //On sauvegarde le score.
    refresh();
    chargerScore();  //On le charge.
    DisplayScore();  //On l'affiche.
  end;

  hasClickedBack:=false;

  if isInMenus then
    sndPlaySound(RES + 'music/opening.wav', SND_ASYNC or SND_LOOP);

  isInMenus:=true;

  labelCreditsMenu.visible:=true;
  labelCreditsMenu.caption:='Credits';
  labelCreditsMenu.top:=630;
  labelCreditsMenu.left:=25;
  labelCreditsMenu.Font.Size:=labelControls.Font.Size;

  n:=0;
  timerDialogue.enabled:=false;
  wait:=0;
  replique:=0;
  enterButton.visible:=true;
  labelDialogue.width:=0;
  peace:=false;
  hasDeclaredWar:=false;
  hasBeenKilled:=false;
  controlsImage.visible:=false;
  labelDialogue.visible:=false;
  backLabel.visible:=false;
  title.visible:=true;   //On affiche les labels souhaités.
  playButton.Visible:=true;
  stageLabel.Visible:=true;
  player1Label.visible:=true;
  player2Label.visible:=true;
  stage1Button.visible:=false;
  stage2Button.visible:=false;
  stage3Button.visible:=false;
  bossButton.visible:=false;
  bottombar.visible:=false;
  TimerPrincipal.enabled:=false;
  labelScore.visible:=false;
  labelVieJ1.visible:=false;
  labelVieJ2.Visible:=false;
  labelBoss.visible:=false;
  labelStore.visible:=false;
  labelBackToGame.visible:=false;
  labelCountDown.visible:=false;
  labelScore.visible:=false;
  labelCredits.visible:=false;
  labelExit.visible:=true;
  freePlayLabel.visible:=false;
  labelControls.visible:=true;
  scoreBoard.visible:=true;
  textBox.visible:=true;
  textBox.caption:=pseudo;
  bossStage:=false;
  piccard.visible:=false;
end;
//Procédure d'amélioration de tirs.
procedure TDynamicShooter.upgradeTirs(Sender:TObject);
begin
  //Si on a assez de crédits et qu'on n'est pas au maximum de nombre de tirs.
  //On se sert de nbTirs pour appeler la procédure spawnTir 1,2 ou 3 fois par pression de la barre d'espace (ou de NUMPAD0).
  if (credits >= newTirPrice) and (nbTirs = 1) then
  begin
    //On incrémente le nombre de tirs.
    nbTirs:=nbTirs + 1;
    //On soustrait le prix à notre quantité d'argent.
    credits:=credits - newTirPrice;
    //On met un nouveau prix.
    newTirPrice:= newTirPrice*4;
  end                             //Si on a déjà deux tirs.
  else if (credits >= newTirPrice) and (nbTirs = 2) then
  begin
    nbTirs:=nbTirs + 1;  //On ajoute un dernier tir.
    credits:=credits - newTirPrice;    //On soustrait le prix.
  end;

  //Si on a moins que 3 tirs, alors on affiche le prix
  if nbTirs <= 2 then
    labelUpgradeTirs.caption:='Add a laser (cost:' + intToStr(newTirPrice) + ')';;

  //Sinon, on est au maximum.
  if nbTirs > 2 then
    labelUpgradeTirs.caption:='Maximum amount of lasers reached!';

  //On mets à jour le label lorsque l'on clicke sur le label
  labelCredits.caption:='Credits:' + intToStr(credits);
end;

//Procédure pour réduire le temps entre chaque tir.
procedure TDynamicShooter.reduceTempsDeTir(Sender:TObject);
var
  i:integer;
begin
  //Si on a assez de crédits. (reduceTirCoolDownPrice est initialisé dans FormCreate).
  if credits >= reduceTirCoolDownPrice then
  begin
    //On soustrait le prix à nos crédits.
    credits:=credits - reduceTirCoolDownPrice;
    //On régle le nouveaux prix.
    reduceTirCoolDownPrice:=reduceTirCoolDownPrice*2;
    //On règle le nouveau temps de tir pour chaque joueur.
    for i:=0 to joueurs.nbJoueurs - 1 do
    begin
      //On soustrait 2 [ms] à chaque achat.
      tempsDeTir:=tempsDeTir - 2;
      joueurs.setTempsDeTirAt(i, tempsDeTir);
    end;
  end;
  //On mets à jour les labels.
  labelCredits.caption:='Credits:' + intToStr(credits);
  labelUpgradeTempsDeTir.caption:='Reduce laser cooldown (cost:' + intToStr(reduceTirCoolDownPrice) + ')';
end;

procedure TDynamicShooter.repairShip(Sender:TObject);
var
  i:integer;
begin
  //Si on a assez de crédits.
  if credits >= repairCost then
  begin
    //On soustrait le prix.
    credits:=credits - repairCost;
    //On règle le nouveau prix.
    repairCost:=repairCost*2;
    //On remet la vie des deux (ou un) joueur à 100.
    for i:=0 to joueurs.nbJoueurs - 1 do
    begin
      //On remet leur vie à 100%.
      joueurs.setVieAt(i, 100);
    end;
  end;
  //On mets à jour les labels.
  labelCredits.caption:='Credits:' + intToStr(credits);
  labelFullRepair.caption:='Repair ship (cost:' + intToStr(repairCost) + ')';
end;

//Procédure qui affiche les labels approprié pour la sélection de stage.
procedure TDynamicShooter.stageSelection();
begin
  labelCreditsMenu.visible:=false;
  isInMenus:=true;
  labelControls.visible:=false;
  playButton.Visible:=false;
  stageLabel.Visible:=false;
  backLabel.visible:=true;
  stage1Button.visible:=true;
  stage2Button.visible:=true;
  stage3Button.visible:=true;
  player1Label.visible:=false;
  player2Label.visible:=false;
  bossButton.visible:=true;
  labelExit.visible:=false;
  freePlayLabel.visible:=true;
end;
procedure TDynamicShooter.labelDeclareWarOnClick(Sender:TObject);
begin
  labelDeclareWar.visible:=false;
  labelPeace.visible:=false;
  labelDialogue.width:=0;
  replique:=replique + 1; //On incrémente la réplique.
   TimerDialogue.enabled:=true; //On ré-active le timer.
end;

procedure TDynamicShooter.labelPeaceOnClick(Sender:TObject);
begin
  peace:=true;
  replique:=9; //On sélectionne la dernière réplique de la liste (10ème cf. dialogue.txt)
  labelDeclareWar.visible:=false;
  labelPeace.visible:=false;
  labelDialogue.width:=0;
  timerDialogue.enabled:=true;
end;

//C'est ici que l'on gère le label de dialogue.
procedure TDynamicShooter.TimerDialogueTimer(Sender:TObject);
begin
  labelDialogue.width:=labelDialogue.width + 12;  //On incrémente constamment sa taille.
  labelDialogue.caption:=repliques[replique];     //On affiche la réplique appropriée.

  if bossStage then    //Si c'est le boss Stage.
  begin
    piccard.visible:=true;
    canChange:=false;  //on la change autre part.
  end;

  if canChange then    //Sinon, on initialise sa taille.
  begin
    labelDialogue.width:=0;
    if not peace then
      replique:=replique + 1;  //On incrémente la réplique si on n'a pas quit.
    canChange:=false;  //On ne change plus, car il faut qu'il affiche le message.
  end;

  if (labelDialogue.width > DynamicShooter.width) and not firstStage then
  begin
    canChange:=true;   //On autorise à changer si on n'a pas encore commencé.
    if peace then
      menuPrincipal(); //Si c'est la paix, on renvoie au menu principal.
  end;

  if firstStage or secondStage or thirdStage then //Si on est en jeu, on ne modifie rien.
    canChange:=false;

  //Si c'est la troisième réplique et qu'elle est totalement affichée.
  if (replique = 3) and (labelDialogue.width >= DynamicShooter.width) then
  begin
    labelDeclareWar.visible:=true; //On affiche les options.
    labelPeace.visible:=true;
    timerDialogue.Enabled:=false;  //On désactive le timer.
  end;

  if (replique = 5) and (labelDialogue.width >= DynamicShooter.width) then
  begin
    firstStage:=true;
    Start();
  end;

  //piccard.visible:=true;
  if firstStage or secondStage or thirdStage then
  begin
    piccard.visible:=false;
    replique:=6;
    labelDialogue.width:=0;
  end;

  if replique = 2 then
    piccard.picture.loadFromFile(RES + 'dialogue/piccard.bmp');
end;

//Procédure pour démarrer le jeu.
procedure TDynamicShooter.Start();
var i:integer;
begin
  labelCreditsMenu.visible:=false;
  isInMenus:=true;
  enterButton.visible:=false;
  playersLose:=false;
  labeLDeclareWar.visible:=false;
  labelPeace.visible:=false;
  wait:=0;
  //On rends les labels appropriés visibles ou pas, idem pour les images.
  freePlayLabel.visible:=false;
  labelControls.visible:=false;
  title.visible:=false;
  PlayButton.visible:=false;
  stageLabel.visible:=false;
  stage1Button.visible:=false;
  stage2Button.visible:=false;
  stage3Button.visible:=false;
  player1Label.visible:=false;
  player2Label.visible:=false;
  bossButton.visible:=false;
  backLabel.visible:=false;
  labelCredits.visible:=true;
  labelExit.visible:=false;
  timerPrincipal.Enabled:=true;
  labelStore.visible:=true;
  bottombar.Visible:=true;
  credits:=0;              //C'est le temps disponible pour la séquence de réparation.
  initialTimeLimit:=670*2; //10*2 secondes. (A cause de l'intervalle du timer de 15 [ms] 1000/15 = 67 = 1 [s])
  nbTirs:=1;               //Paramètres initiaux.
  newTirPrice:=60;
  reduceTirCoolDownPrice:=40;
  repairCost:=20;
  scoreBoard.Visible:=false;
  textBox.Visible:=false;

  //J'instantie la classe joueurs.
  joueurs:=TPlayerObject.Create(bottombar);


  labelPeace.visible:=false;
  labelDeclareWar.visible:=false;

  //création des ArrayDynamique.
  tirsJoueur:= TDynamicArray.Create;
  ennemis:=TDynamicArray.Create;
  tirsEnnemi:=TDynamicArray.Create;
  tirsBoss:=TDynamicArray.Create;


  //Confirmed destruction est la varibale dont nous nous servons
  //pour savoir si la procédure de réparation est active ou pas.
  confirmDestruction:=false;
  joueurs.confirmedDestruction:=false;

  //Variable de destruction des TSpaceShipSystem.
  destruction:=0;
  //Attente ennemi est la variable qui gère le temps entre chaque appel de spawnEnnemi.
  //C'est la variable qui s'incrémente et qu'on compare à tempsEnnemi, avant de spawn un ennemi.
  attenteEnnemi:=0;

  //Séléction des paramètres pour chaque stage.
  if freePlay then
  begin
    score:=0;
  end;

  if firstStage then
  begin
    //On règle le score, car c'est en fonction du score que les paramètres du stage
    //sont modifiés dans le timer principal.
    score:=1000;
    secondStage:=false;
    thirdStage:=false;
    bossStage:=false;
    //On donne un minimum de crédits pour pouvoir survivre.
    credits:=60;
  end;

  if secondStage then     //On se sert de ces booleans uniquement pour pouvoir
  begin                   //Choisir un niveau.
    score:=2500;
    firstStage:=false;
    thirdStage:=false;
    bossStage:=false;
    credits:=120;
  end;

  if thirdStage then
  begin
    score:=4000;
    firstStage:=false;
    secondStage:=false;
    bossStage:=false;
    credits:=240;
  end;

  if bossStage then
  begin
    //On règle le temps entre chaque tir du boss.
    wait:=0;
    labelBoss.Visible:=true;
    replique:=6;
    bossCoolDown:=20;
    firstStage:=false;
    secondStage:=false;
    thirdStage:=false;
    score:=6000;
    credits:=400;
  end;

  ennemiSpeed1:=10;
  ennemiSpeed2:=5;
  ennemiSpeed3:=2;

  labelVieJ1.Visible:=true;
  labelVieJ2.Visible:=true;
  labelScore.Visible:=true;

  for i:=0 to nbInitialJoueurs do
  begin
    //J'ajoute un joueur à ma classe.
    createPlayerObject();
    bossCounter:=0;
  end;
end;

procedure TDynamicShooter.store(Sender:TObject);
var
  i,o,p,l,q,u,r,e:integer;
begin
  labelDialogue.visible:=false;
  TimerPrincipal.Enabled:=false;
  //On rends tout invisible.
  for i:=0 to tirsJoueur.NumberElement - 1 do
    tirsJoueur.getImageAt(i).visible:=false;

  for o:=0 to ennemis.NumberElement - 1 do
    ennemis.getImageAt(o).visible:=false;

  for p:=0 to tirsEnnemi.NumberElement - 1 do
    tirsEnnemi.getImageAt(p).visible:=false;

  for q:=0 to joueurs.nbJoueurs - 1 do
  begin
    joueurs.getShieldAt(q).image.visible:=false;
    joueurs.getLaserAt(q).visible:=false;
    joueurs.getImageAt(q).visible:=false;
    joueurs.getImageAt(q).top:=-200;

    for r:=0 to joueurs.nbMines - 1 do
      joueurs.getMinesAt(q, r).Visible:=false;
  end;

  if bossStage then
  begin
    for l:=0 to tirsBoss.NumberElement - 1 do
      tirsBoss.getImageAt(l).visible:=false;

    boss.vaisseau.visible:=false;

    for u:=0 to length(boss.lasers) - 1 do
      boss.lasers[u].image.visible:=false;

    for e:=0 to length(boss.mines) - 1 do
      boss.mines[e].imageMine.visible:=false;
  end;

  //Idem pour les labels.
  labelStore.visible:=false;
  bottombar.visible:=false;
  labelVieJ1.visible:=false;
  labelScore.visible:=false;
  labelVieJ2.visible:=false;
  labelBoss.visible:=false;
  labelBackToGame.visible:=true;
  labelUpgradeTirs.visible:=true;

  //On mets à jour les labels du store.
  if nbTirs < 3 then
    labelUpgradeTirs.caption:='Add a laser (cost:' + intToStr(newTirPrice) + ')';

  if nbTirs = 3 then
    labelUpgradeTirs.caption:='Maximum amount of lasers reached!';

  labelUpgradeTempsDeTir.visible:=true;
  labelFullRepair.visible:=true;
  labelFullRepair.caption:='Repair ship (cost:' + intToStr(repairCost) + ')';
  labelUpgradeTempsDeTir.caption:='Reduce laser cooldown (cost:' + intToStr(reduceTirCoolDownPrice) + ')';
end;

procedure TDynamicShooter.backToGameButtonClick(Sender:TObject);
var
  i,e,p,l,q,r,o:integer;
begin
  //On réactive le timer.
  TimerPrincipal.enabled:=true;
  labelDialogue.visible:=true;
  //On réactive les labels.
  labelStore.visible:=true;
  bottombar.visible:=true;
  labelVieJ1.visible:=true;
  labelScore.visible:=true;
  labelStore.visible:=true;
  labelBackToGame.visible:=false;
  labelUpgradeTirs.visible:=false;
  labelUpgradeTempsDeTir.visible:=false;
  labelFullRepair.visible:=false;

  //On rends tout visible.
  for i:=0 to tirsJoueur.NumberElement - 1 do
    tirsJoueur.getImageAt(i).visible:=true;

  for o:=0 to ennemis.NumberElement - 1 do
    ennemis.getImageAt(o).visible:=true;

  for p:=0 to tirsEnnemi.NumberElement - 1 do
    tirsEnnemi.getImageAt(p).visible:=true;

  for q:=0 to joueurs.nbJoueurs - 1 do
  begin
    joueurs.getImageAt(q).visible:=true;
    joueurs.getImageAt(q).top:=round(DynamicShooter.Height * (3/4));
    for r:=0 to joueurs.nbMines - 1 do
      joueurs.getMinesAt(q, r).Visible:=true;
  end;

  //On rends le boss visible si c'est un bossStage...
  if bossStage then
  begin
    for l:=0 to tirsBoss.NumberElement - 1 do
      tirsBoss.getImageAt(l).visible:=true;

    for q:=0 to length(boss.lasers) - 1 do
      boss.lasers[q].image.visible:=true;

    for e:=0 to length(boss.mines) - 1 do
      boss.mines[e].imageMine.visible:=false;

    boss.vaisseau.visible:=true;
    labelBoss.visible:=true;
  end;

  //Si il y a deux joueurs, on rends le label du deuxième visible.
  if joueurs.nbJoueurs > 1 then
    labelVieJ2.visible:=true;
end;

//Procédure de création de joueur.
procedure TDynamicShooter.createPlayerObject();
var newPlayer:TPlayer;
    i,b:integer;
begin
  n := n + 1;
  //Je configure mon joueur.
  //Création de son image via createImage, (évie 6 lignes de code redondantes.)
  newPlayer.image:=createImage('./ressources/players/player' + intToStr(n) + '.bmp', 50, 50, true, DynamicShooter.width div 2 - 25, DynamicShooter.height div 2 - 25);
  newPlayer.image.stretch:=true;
  newPlayer.image.transparent:=true;
  newPlayer.xp_speed:=0;
  newPlayer.yp_speed:=0;                 //Mais ce n'est pas le cas lorsque l'on meurt.
  newPlayer.vitesse_maximale_joueur:=8;  //Bug: la vitesse maximale semble doubler quand on recommence?
  newPlayer.image.top:=DynamicShooter.height div 2 - newPlayer.image.height div 2;
  newPlayer.image.left:=DynamicShooter.width div 2 - newPlayer.image.width*(n-1) - n;
  newPlayer.vie:=100;
  tempsDeTir:=15;
  newPlayer.tempsDeTir:=tempsDeTir;
  newPlayer.shootCoolDown:=0;

  //Configuration du bouclier.
  newPlayer.shield.image:=createImage(SHIELD_PATH, 100, 20, false, -200, -200);
  newPlayer.shield.image.transparent:=true;
  newPlayer.shield.vie:=20;
  newPlayer.shield.coolDown:=500;

  //Configuration du laser.
  newPlayer.laser:=createImage(LASER_PATH, 50, 1000, false, -200, -200);
  newPlayer.laserCoolDown:= 500;
  newPlayer.laser.Transparent:=true;

  //Configuration du jet.
  newPlayer.jetCoolDown:=0;

  //Configuration des mines.
  nbMines:= length(newPlayer.mines);
  //Norme de la vitesse.
  b:=8;
  //On parcour le tableau de joueurs.
  for i:=0 to length(newPlayer.mines) - 1 do
  begin
    //On crée les mines...
    newPlayer.mines[i].imageMine:=createImage(PLAYER_MINE, 20, 20, false, 0, 2000);
    newPlayer.mines[i].imageMine.Transparent:=true;
    //On donne les vitesses avec un sinus/cosinus.
    newPlayer.mines[i].v_x:=round(cos(degToRad(180/(length(newPlayer.mines))*i))*b);
    newPlayer.mines[i].v_y:=-round(sin(degToRad(180/(length(newPlayer.mines))*i))*b);
  end;
  //On initialise le cooldown des mines.
  newPlayer.minescoolDown:= 250;

  joueurs.addPlayer(newPlayer);
end;

//Procédure de création d'ennemi.
procedure TDynamicShooter.SpawnEnnemi(path: string; vie: integer; vitesse_y:integer);
var nouveauEnnemi:TVaisseaux;
begin
  //Je configure mon ennemi.
  //nouveauEnnemi.image:=createImage('./ressources/' + path, 50, 50, true, -200, -200);
  //J'aimerais bien me servir de cette fonction mais elle aligne mes ennemis bizzarement...
  nouveauEnnemi.image:=TImage.Create(self);
  nouveauEnnemi.image.parent:=self;

  nouveauEnnemi.image.picture.LoadFromFile(path);
  nouveauEnnemi.image.SendToBack;
  nouveauEnnemi.image.stretch:=true;
  nouveauEnnemi.image.width:=50;
  nouveauEnnemi.image.height:=50;
  nouveauEnnemi.image.visible:=true;
  nouveauEnnemi.image.transparent:=true;

  nouveauEnnemi.image.top:= -nouveauEnnemi.image.Height;
  //On le spawn quelque part dans l'écran.

  nouveauEnnemi.image.left:= random(DynamicShooter.width - nouveauEnnemi.image.width);
  nouveauEnnemi.Vie:= vie; //On règle la vie de l'ennemi.

  //Configuration des vitesses transverales et latérales.
  nouveauEnnemi.v_x:= random(2) + 1;
  nouveauEnnemi.v_y:=vitesse_y;
  nouveauEnnemi.direction:= random(2) + 1;

  //On l'ajoute à notre tableau dynamique.
  ennemis.AddElement(nouveauEnnemi);
end;
//Procédure qui fait apparaître les tirs des ennemis et des joueurs.
procedure TDynamicShooter.SpawnTir(path: string; index:integer; genre: string);
var nouveauTir:TVaisseaux;
begin
  nouveauTir.image:= TImage.Create(self);  //Je crée un lien entre nouveau tir et une image.
  nouveauTir.image.Parent:= self;          //Je lui assigne le form en tant que parent.

  //Propriétés de l'image.
  nouveauTir.image.stretch:=true;
  nouveauTir.image.width:=14;
  nouveauTir.image.height:=30;
  nouveauTir.image.visible:=true;
  nouveauTir.image.transparent:=true;
  nouveauTir.Vie:=0;

  //Si c'est un ennemi, on le spawn sur un ennemi.
  if genre = 'ennemi' then
  begin
    nouveauTir.image.picture.loadfromfile(path);
    nouveauTir.image.top:=ennemis.getImageAt(index).top;   //On lui donne sa position.
    nouveauTir.image.left:=ennemis.getImageAt(index).left + 20;
    tirsEnnemi.AddElement(nouveauTir); //je rajoute un élément au tableau dynamique de tirs ennemis.
    nouveauTir.v_y:= -VITESSE_TIRS;
  end     //Si c'est un joueur, on le spawn sur le joueur en fonction de 3 textures différentes.
  else if genre = 'joueur' then
  begin
    nouveauTir.image.picture.loadfromfile(path);     //(Chaque texture à sa position)
    nouveauTir.image.top:=joueurs.getImageAt(index).top;
    nouveauTir.v_y:= VITESSE_TIRS;
    if path = PATH_TIR_1 then
    begin
      nouveauTir.image.top:=joueurs.getImageAt(index).top - nouveauTir.image.height;
      nouveauTir.image.left:=joueurs.getImageAt(index).left + joueurs.getImageAt(index).width div 2 - nouveauTir.image.width div 2;
    end   //Path est un paramètre de la procédure.
    else if path = PATH_TIR_2 then
    begin
      nouveauTir.image.left:=joueurs.getImageAt(index).left + joueurs.getImageAt(index).width - nouveauTir.image.width div 2;
    end
    else if path = PATH_TIR_3 then
    begin
      nouveauTir.image.left:=joueurs.getImageAt(index).left - nouveauTir.image.width div 2;
    end;
    tirsJoueur.AddElement(nouveauTir); //Ici on rajoute le tir au tableau des joueurs.
  end
  else if genre = 'boss' then    //Si c'est un boss...
  begin
    nouveauTir.image.picture.loadFromFile(path);
    randomize;
    nouveauTir.direction:= random(2);  //La direction est utilisée pour savoir sur quel cannon spawner le tir.
    nouveauTir.image.Transparent:=true;

    nouveauTir.image.width:=20;  //Ne pas mettre un transparent sur une image à une couleur!
    nouveauTir.image.height:=40;
    nouveauTir.v_y:=15;
    nouveauTir.image.top:= boss.lasers[0].image.Height;

    //On le fait spawn sur l'un ou l'autre des cannons.
    if nouveauTir.direction = 0 then
      nouveauTir.image.left:= boss.lasers[0].image.left + boss.lasers[0].image.width div 2;  //On le spawn sur l'un ou l'autre des lasers du boss.
                                                                                //(Les boîtes qui se déplacent)
    if nouveauTir.direction = 1 then
      nouveauTir.image.left:= boss.lasers[1].image.left + boss.lasers[1].image.width div 2;

    tirsBoss.AddElement(nouveauTir); //Ici on rajoute le tir au tirs du boss.
  end;
end;

//Procédure de création du Boss.
procedure TDynamicShooter.createBoss();
var
  i,o,b:integer;
begin
  piccard.picture.loadFromFile(RES + 'dialogue/einstein.bmp');
  replique:=6;
  labelDialogue.width:=0;
  firstStage:=false;
  secondStage:=false;
  thirdStage:=false;
  bossStage:=true;

  //Configuration de l'image du boss.
  boss.vaisseau:=createImage(BOSS_PATH, 600, DynamicShooter.height div 4, true, 0, 0);
  boss.vaisseau.Transparent:=true;
  //Configuration des variables integer du boss.
  boss.TirCoolDown:=bossCoolDown;
  boss.bossCount:=0;
  boss.vie:=10000;
  boss.vaisseau.Transparent:=true;
  boss.vaisseau.SendToBack; //Pour éviter d'avoir des superpositions et continuer à voir les labels.
  background1.SendToBack;
  background2.SendToBack;
  labelBoss.visible:=true;

  //On rempli le tableau des tirs du boss.
  for i:=0 to length(boss.lasers) - 1 do
  begin
    boss.lasers[i].image:=createImage(BOSSLASER_PATH, 90, 90, true, 0, 20);
    boss.lasers[i].image.Transparent:=true;
    //boss.lasers[i].image.top:=boss.vaisseau.top;
    boss.lasers[i].damage:=200;
  end;

  //Positions initiales des systèmes lasers.
  boss.lasers[0].image.left:=0;
  boss.lasers[1].image.left:= boss.vaisseau.width - boss.lasers[1].image.width;

  boss.lasers[0].v_x:=10;
  boss.lasers[0].image.Picture.LoadFromFile(RES + 'boss/lasers1.bmp');
  boss.lasers[1].v_x:=-10;
  boss.lasers[1].image.Picture.LoadFromFile(RES + 'boss/lasers.bmp');

  //Initialisation du tableau de mines du boss.
  b:=8;
  for o:=0 to length(boss.mines) - 1 do
  begin
    boss.mines[o].imageMine:=createImage(BOSSMINES_PATH, 20, 20, false, boss.vaisseau.width div 2 - 10, boss.vaisseau.top);
    boss.mines[o].imageMine.Stretch:=true;
    boss.mines[o].imageMine.Transparent:=true;
    //On donne les vitesses avec un sinus/cosinus.
    boss.mines[o].v_x:=round(cos(degToRad(180/(length(boss.mines)))*o)*b);
    boss.mines[o].v_y:=round(sin(degToRad(180/(length(boss.mines)))*o)*b);
  end;

  //Configuration des propriétés des mines.
  boss.mineCoolDown:=200;
  boss.activeMines:=false;
end;

function TDynamicShooter.Collide(ennemi: TImage; tir: TImage) : boolean;
begin
  //Procédure de collision entre les tirsJoueur, ennemis, tirs du joueur...
  if (tir.top <= ennemi.top + ennemi.height) and
  (tir.left >= ennemi.left - 10) and
  (tir.left <= ennemi.left + ennemi.width + 10) and
  (tir.top >= ennemi.top) then
  begin
    result:=true;
  end
  else
  begin
    result:=false;
  end;
end;

//On regroupe les algorithmes de collision ici pour que le timer soit plus propre.
procedure TDynamicShooter.collisions();
var
  a,b,o,l,f,d,e,g,z,u,p,s,nbMine:integer;
begin
   //Algorithmes de collisions.
   for a:= 0 to ennemis.NumberElement - 1 do
   begin
     //Si les ennemis sont en dehors de l'écran on change leur vitesse en x.
     if ennemis.getImageAt(a).left < 0 then
       ennemis.setVxAt(a, -ennemis.getVxAt(a));
     if ennemis.getImageAt(a).left + ennemis.getImageAt(a).width > DynamicShooter.Width then
       ennemis.setVxAt(a, -ennemis.getVxAt(a));

     for o:=0 to joueurs.nbJoueurs - 1 do
     begin
       //Collision entre joueurs et ennemis.
       if Collide(joueurs.getImageAt(o), ennemis.getImageAt(a)) then
       begin
         if ennemis.getImageAt(a).visible and not bossStage then
         begin
           confirmDestruction:=true;
           joueurs.confirmedDestruction:=true;
           break;
         end;
       end;

       //Si le laser touche les ennemis.
       if Collide(joueurs.getLaserAt(o), ennemis.getImageAt(a)) and (joueurs.getLaserAt(o).visible = true) then
       begin
         ennemis.getImageAt(a).visible:=false;
       end;
       for nbMine:= 0 to nbMines - 1 do
       begin
         //Si une collision à lieu entre mes ennemis et mes tirs, alors on élimine les ennemis.
         if Collide(ennemis.getImageAt(a), joueurs.getMinesAt(o, nbMine)) then
         begin
           ennemis.getImageAt(a).visible:=false;
           ennemis.getImageAt(a).top:=DynamicShooter.height*2;
           ennemis.getImageAt(a).top:= -200;
         end;
       end;
     end;


     for u:=0 to tirsJoueur.NumberElement - 1 do
     begin
       //Collisions entre ennemis et les tirs du Joueur.
       if Collide(ennemis.getImageAt(a), tirsJoueur.getImageAt(u)) then
       begin
         //Ils doivent être visibles.
         if (ennemis.getImageAt(a).visible) and (tirsJoueur.getImageAt(u).visible) then
         begin
           //On baisse la vie des ennemis.
           ennemis.setVieAt(ennemis.getVieAt(a) - 1, a);
           //On les replace en arrière.
           ennemis.getImageAt(a).Top:=ennemis.getImageAt(a).top - 10;
           //On gagne des crédits.
           credits:=credits + 1;
           //On rends les tirs invisibles.
           tirsJoueur.getImageAt(u).visible:=false;
           //Si la vie de l'ennemi est nulle ou négative.
           if ennemis.getVieAt(a) <= 0 then
           begin
             //On les rends invisibles.
             ennemis.getImageAt(a).visible:=false;
             ennemis.getImageAt(a).top:= 1000;
             break;
           end;
         end;
       end;
     end;
   end;


   //Collisions entre le joueur et les tirs des ennemis et les pouvoirs.
   for l:=0 to tirsEnnemi.NumberElement - 1 do
   begin
     for f:=0 to joueurs.nbJoueurs - 1 do
     begin
       //Collision du bouclier avec les tirs des Ennemis.
       if Collide(joueurs.getShieldAt(f).image, tirsEnnemi.getImageAt(l)) and (joueurs.getShieldAt(f).image.visible) then
       begin
         tirsEnnemi.getImageAt(l).visible:=false;
         joueurs.setShieldLifeAt(f, joueurs.getShieldAt(f).vie - 1);
       end;

       //Si la vie du bouclier est négative, on le désactive.
       if joueurs.getShieldAt(f).vie <= 0 then
       begin
         joueurs.getShieldAt(f).coolDown:= 400;
         joueurs.getShieldAt(f).vie:= 20;
         joueurs.getShieldAt(f).image.Visible:=false;
       end;

       //Si il y a une collision.                                         //Si le bouclier n'est pas visible...
       if Collide(joueurs.getImageAt(f), tirsEnnemi.getImageAt(l)) and not (joueurs.getShieldAt(f).image.visible) then
       begin
         //On décrémente la vie.
         joueurs.setVieAt(f, joueurs.getVieAt(f)-1);
         //On rends l'image invisible.
         tirsEnnemi.getImageAt(l).visible:= false;
       end;
     end;
   end;

   //Collisions si le boss est actif.
   if bossStage then
   begin
     //Collisions entre les joueurs et les tirs du boss.
     for d:= 0 to joueurs.nbJoueurs - 1 do
     begin
       for z:=0 to tirsBoss.NumberElement - 1 do
       begin //Si il y a une collision entre les joueurs et les tirs du boss et que le bouclier n'est pas actif.
         if Collide(joueurs.getImageAt(d), tirsBoss.getImageAt(z)) and not (joueurs.getShieldAt(d).image.visible) then
         begin
           //On décrémente la vie du joueur.
           joueurs.setVieAt(d, joueurs.getVieAt(d)-2); //(-2 car c'est des gros lasers)
           tirsBoss.getImageAt(z).visible:=false; //On rends les tirs invisibles.
         end;

         //Si il y a une collision entre le bouclier et les tirs du boss...
         if Collide(joueurs.getShieldAt(d).image, tirsBoss.getImageAt(z)) then
         begin
           joueurs.setShieldLifeAt(d, joueurs.getShieldAt(d).vie - 1);  //On décrémente la vie du bouclier du joueur.
           tirsBoss.getImageAt(z).visible:=false;                       //On rends les tirs du boss invisibles.
         end;
         //Si il y a une collision entre les joueurs et les mines, alors...
         for s:=0 to length(boss.mines) - 1 do
         begin
           if Collide(joueurs.getImageAt(d), boss.mines[s].imageMine) and not (joueurs.getShieldAt(d).image.visible) then
           begin
             //Je rends la mine invisible.
             boss.mines[s].imageMine.visible:=false;
             //Je décrémente la vie.
             joueurs.setVieAt(d, joueurs.getVieAt(d) - 1);
           end;
           //Si il y a une collision alors que le bouclier est visible...
           if Collide(joueurs.getImageAt(d), boss.mines[s].imageMine) and (joueurs.getShieldAt(d).image.visible) then
           begin
             boss.mines[s].imageMine.visible:=false;  //On rends la mine invisible.
             joueurs.setShieldLifeAt(d, joueurs.getShieldAt(d).vie - 5); //On décrémente la vie du bouclier.
           end;
         end;
       end;
     end;

     //Collisions entre les tirs du joueur et le boss.
     for p:=0 to tirsJoueur.NumberElement - 1 do
     begin
       if (tirsJoueur.getImageAt(p).top <= 100) then
       begin
         tirsJoueur.getImageAt(p).visible:=false; //On rends les tirs invisibles.
         boss.vie:=boss.vie - 1;                  //On décrémente la vie du boss.
       end;
     end;

     for g:=0 to joueurs.nbJoueurs - 1 do
     begin
       if joueurs.getLaserAt(g).visible then //Si le laser est actif, on sait qu'il touche le boss.
         boss.vie:=boss.vie - 5;  //On décrémente donc sa vie.
     end;
    //Collisions entrel le boss et les mines du joueur.
     for b:=0 to joueurs.nbJoueurs - 1 do
     begin
       for e:=0 to nbMines - 1 do
       begin         //Si les mines sont visibles (donc actives)
         if joueurs.getMinesAt(b,e).Visible then    //Et qu'elles touchent le vaisseau.
           if Collide(boss.vaisseau, joueurs.getMinesAt(b, e)) then
             boss.vie:=boss.vie - 5; //On décrémente la vie du boss.
       end;
     end;
   end;
   labelBoss.caption:='HP:' + intToStr(boss.vie div 100) + '%'; //On mets à jour la vie du boss.
end;
//Procédure de déplacement.
procedure TDynamicShooter.move(elementMoved: TDynamicArray; genre:string);
var i,k:integer;
    tmpImage:TImage;
begin
  if genre = 'tirs' then
  begin
    for i:=0 to elementMoved.NumberElement - 1 do
    begin
      tmpImage:= elementMoved.getImageAt(i); //On prends l'image à cette case.
      tmpImage.top:= tmpImage.top + elementMoved.getVyAt(i); //On la déplace.
      elementMoved.setImageAt(i, tmpImage);
    end;
  end;
  //Pour faire déplacer mes ennemis différement entre eux.
  if genre = 'ennemis' then
  begin
    for k:=0 to elementMoved.NumberElement - 1 do
    begin
      tmpImage:= elementMoved.getImageAt(k);
      //On incrémente la position en Y avec la vitesse appropriée.
      tmpImage.top:= tmpImage.top + elementMoved.getVyAt(k);
      randomize;

      //Boolean initialisé lors de la création de l'ennemi.
      if elementMoved.getDirectionAt(k) = 1 then
      begin
        tmpImage.left:= tmpImage.left + elementMoved.getVxAt(k);
      end
      else if elementMoved.getDirectionAt(k) = 2 then
      begin
        tmpImage.left:= tmpImage.left - elementMoved.getVxAt(k);
      end;
      elementMoved.setImageAt(k, tmpImage);
    end;
  end;
end;

procedure TDynamicShooter.defileFond(firstBackground: TImage; secondBackground:TImage; vitesse:integer);
begin
  //Si le fond est en dehors on le replace en haut.
  if firstBackground.top >= DynamicShooter.height then
  begin
     firstBackground.top:= -DynamicShooter.height;
     secondBackground.top:= 0;
  end;

  //Idem.
  if secondBackground.top >= DynamicShooter.height then
  begin
     secondBackground.top:= -DynamicShooter.height;
     firstBackground.top:= 0;
  end;

  //On déplace les fonds avec une variable, vitesseFond qui change en fonction du stage.
  firstBackground.top:=firstBackground.top + vitesse;
  secondBackground.top:=secondBackground.top + vitesse;

end;

//Procédure qui gère les appels de tirs.
procedure TDynamicShooter.Shoot(player:integer);
begin
  if joueurs.getShootCoolDown(player) >= joueurs.getTempsDeTir(player) then
    begin
      //On appelle SpawnTir avec la texture et la position appropriée.
      case nbTirs of
        1:          //Si on a qu'un seul tir, on n'en spawn qu'un seul.
        begin
          SpawnTir(PATH_TIR_1, player, 'joueur');
        end;
        2:
        begin              //Si on en a deux, on en fait deux.
          SpawnTir(PATH_TIR_2, player, 'joueur');
          SpawnTir(PATH_TIR_3, player, 'joueur');
        end;
        3:
        begin              //Si on en a trois, on en fait trois.
          SpawnTir(PATH_TIR_1, player, 'joueur');
          SpawnTir(PATH_TIR_2, player, 'joueur');
          SpawnTir(PATH_TIR_3, player, 'joueur');
        end;
      end;
    //On remet le cooldown à zéro pour le joueur 0.
    joueurs.setShootCoolDownAt(player,0);
  end;
end;

procedure TDynamicShooter.TimerPrincipalTimer(Sender: TObject);
var i,z,q,h,p,w,g,we,wo,y,texture:integer;
begin
  //Appel de la procédure pour faire défiler le fond.
  defileFond(background1, background2, vitesseFond);
  background1.SendToBack;
  background2.SendToBack;
  vitessefond:=score div 800; //On règle la vitesse du fond en fonction du score.

  //Appel de la procédure de collision.
  collisions();

  //Procédures de déplacement des joueurs.
  //On navigue les joueurs.
  for h:=0 to joueurs.nbJoueurs - 1 do
  begin
    //On initialise les horloges des joueurs.
    //On déplace les joueurs.
    joueurs.move(h);
    //On active leurs pouvoirs.
    joueurs.activatePowers(h);
    //On affiche leur vies respectives.
    labelVieJ1.caption:='HP:' + IntToStr(joueurs.getVieAt(JOUEUR_1)) + '%';
    if joueurs.nbJoueurs > 1 then //On mets une condition pour éviter une erreur d'accès et recevoir un longInt.
      labelVieJ2.caption:='HP:' + IntToStr(joueurs.getVieAt(JOUEUR_2)) + '%';
  end;

  //appel de procédure de déplacement pour les ennemis, tirsJoueur, tirsEnnemis et les tirs du boss.
  move(ennemis, 'ennemis');
  move(tirsJoueur, 'tirs');
  move(tirsEnnemi, 'tirs');
  move(tirsBoss, 'tirs');

  if(GetKeyState(ord('P')) < 0) then
    Store(Sender);

  //Appel de procédures pour faire apparaitre les tirs des ennemis.
  EnnemiCoolDown:=EnnemiCoolDown + 1;
  //Si ennemiCoolDown est plus grand que le temps de tir, je spawn un ennemi.
  if ennemiCoolDown >= tempsDeTirEnnemi then
  begin
    //On parcoure tout le tableau d'ennemis.
    for i:=0 to ennemis.NumberElement - 1 do
    begin
      //Si l'ennemi est visible, je le fait tirer, sinon c'est qu'il est mort.
      if ennemis.getImageAt(i).visible then
      begin
        //Je choisit la texture de tir aléatoirement.
        texture:= random(4);
        if texture = 1 then
        begin
          //Je spawn le tir, à l'index i qui correspond à l'ennemi en question,
          //et on précise le genre car spawnTir gère les tirs des joueurs et des ennemis
          //qui ont des vitesses différentes
          SpawnTir(PATH_TIRENNEMI_1, i, 'ennemi');
        end
        else if texture = 2 then
        begin
          SpawnTir(PATH_TIRENNEMI_2, i, 'ennemi');
        end
        else if texture = 3 then
        begin
          SpawnTir(PATH_TIRENNEMI_3, i, 'ennemi');
        end;
        //On remet le cooldown à 0, que l'on réincrémente au prochain cycle du timer.
        ennemiCoolDown:=0;
      end;
    end;
  end;

  //Shoot cooldown est le cooldown de chacun de mes joueurs, il n'est pas commun,
  //c'est donc partie de ma classe.
  for p:=0 to joueurs.nbJoueurs - 1 do
  begin
    //Je l'incrémente pour chaque joueur à chaque cycle de timer.
    joueurs.setShootCoolDownAt(p, joueurs.getShootCoolDown(p) + 1);
  end;

  //Procédure de tir.
  //Si j'appuie sur espace, je tire.
  //Appel des procédures de tir pour le premier joueur.
  if (GetKeyState(ord(VK_SPACE)) < 0) then
    Shoot(0); //0 est la première case de mon tableau de TPlayers de ma classe TPlayerObject.

  if (GetKeyState(ord(VK_NUMPAD0)) < 0) then
    Shoot(1);


  //Procédure de spawn des ennemis.
  attenteEnnemi:=attenteEnnemi + 1;
  if(attenteEnnemi >= tempsEnnemi) then
    begin
      //On fait apparaître les ennemis trois par trois.
      randomize;
      SpawnEnnemi(PATH_ENNEMI_1, 1, ennemiSpeed1);  //Rouge
      SpawnEnnemi(PATH_ENNEMI_2, 2, ennemiSpeed2);  //Jaune
      SpawnEnnemi(PATH_ENNEMI_3, 3, ennemiSpeed3);  //Gris
      //On remet l'attente à 0.
      attenteEnnemi:=0;
      //Si le boss est actif on choisit le temps de spawn plus chaotiquement.
      if bossStage then
        tempsEnnemi:=random(50) + 80;
    end;

  //Si le joueur est mort.
  if joueurs.nbJoueurs = 1 then
    if joueurs.getVieAt(0) < 0 then
    begin
      //L'image ne veut pas devenir invisible, donc je le place en dehors...
      labelVieJ1.caption:='Dead';
      joueurs.getImageAt(0).top:= -2000;
      //On rends l'image invisible.
      joueurs.getImageAt(0).visible:=false;
      playersLose:=true;
      credits:=0;
    end;

  if playersLose then
  begin
    if bossStage then
    begin
      if (labelDialogue.width > DynamicShooter.width) and (replique = 7) then
      begin
        labelDialogue.width:=0;
      end;
    end;
    replique:=8;
    wait:=wait + 1;
  end;


  //Si il y a deux joueurs.
  if joueurs.nbJoueurs = 2 then
  begin
    //Si le premier meurt.
    if (joueurs.getVieAt(0) < 0) then
    begin
      //On le sort de l'écran.
      joueurs.getImageAt(0).top:= -2000;  //On les replace car l'image ne veut pas devenir invisible...
      //On affiche 'Dead' sur le label de sa vie.
      labelVieJ1.caption:='Dead';
    end;
    //Idem avec le deuxième joueur.
    if(joueurs.getVieAt(1) < 0) then
    begin
      joueurs.getImageAt(1).top:= -2000;
      labelVieJ2.caption:='Dead';
    end;
    //Si les deux sont morts par contre,
    if (joueurs.getVieAt(0) < 0) and (joueurs.getVieAt(1) < 0) then
    begin
      joueurs.getImageAt(1).top:= -2000; //On les replace.
      joueurs.getImageAt(0).top:= -2000;
      playersLose:= true;
      credits:=0;
    end;
  end;

  //Si la capacité du jet à été utilisée et que le cooldown est plus petit que 100,
  for g:=0 to joueurs.nbJoueurs - 1 do
  begin
    if joueurs.getJetCoolDownAt(g) <= 100 then
      joueurs.setTempsDeTirAt(g, tempsDeTir); //On remets le temps de tir normal.
  end;                                        //On fait ceci ici car on ne peut accéder à tempsDeTir
                                              //depuis U_Player.
  //On décrémente le cooldown des mines du boss.
  if boss.mineCoolDown > 0 then
    boss.mineCoolDown:= boss.mineCoolDown - 1;

  //Procédure de supression des ennemis lorsqu'ils sont en dehors du cadre.
  //Le string est un paramètre, car il faut une condition différente à chaque fois.
  EnDehors(ennemis, 'ennemi');
  //procédure de suppression des tirsEnnemis lors de collision avec le cadre.
  EnDehors(tirsEnnemi, 'tirEnnemi');
  //Idem pour tirs joueur.
  EnDehors(tirsJoueur, 'tirJoueur');
  //Idem pour les tirs du boss.
  EnDehors(tirsBoss, 'tirEnnemi');

  //Gardez ce bout de code à la fin! (Pour éviter les erreurs d'accès)
  //Si il y a eu une collision entre le joueur et l'ennemi...
  if confirmDestruction then
  begin
    TimerPrincipal.Enabled:=false;
    //On configure l'arène d'invasion.
    EmptyScreen();
    CreateDestruction();
    //On active le timer de la séquence de destruction.
    TimerDestruction.enabled:=true;
  end;

  //Algorithme de difficulté en fonction du score.
  labelScore.caption:= 'Score:' + intToStr(score);
  case score of
  0:
    begin //'Stage 0.'
      tempsEnnemi:=90;   //On règle le temps de spawn des ennemis.
      ennemiSpeed1:=6;   //On règle la vitesse des ennemis.
      ennemiSpeed2:=4;
      ennemiSpeed3:=2;
      tempsDeTirEnnemi:=100;  //On règle leur fréquence de tirs.
    end;
  1000:
    begin
      tempsEnnemi:=70;  //Stage 1.
      ennemiSpeed1:=10;
      ennemiSpeed2:=6;
      ennemiSpeed3:=4;
      tempsDeTirEnnemi:=90;
      sndPlaySound(RES + 'music/theme1.wav', SND_ASYNC or SND_LOOP);
    end;
  2500:
    begin
      tempsEnnemi:=50;  //Stage 2.
      ennemiSpeed1:=10;
      ennemiSpeed2:=8;
      ennemiSpeed3:=6;
      tempsDeTirEnnemi:=80;
      sndPlaySound(RES + 'music/theme2.wav', SND_ASYNC or SND_LOOP);
    end;
  4000:
    begin
      tempsEnnemi:=40; //Stage 3.
      ennemiSpeed1:=6;
      ennemiSpeed2:=5;
      ennemiSpeed3:=7;
      tempsDeTirEnnemi:=60;
      sndPlaySound(RES + 'music/theme3.wav', SND_ASYNC or SND_LOOP);
    end;
  6000:
    begin
      tempsEnnemi:=120;
      tempsEnnemi:=60;
      tempsDeTirEnnemi:=50;
      ennemiSpeed1:=1;
      ennemiSpeed2:=1;
      ennemiSpeed3:=1;
      if not freePlay then //Si le mode freePlay n'est pas choisi,
      begin                //on fait spawn le boss.
        createBoss();
        sndPlaySound(RES + 'music/boss.wav', SND_ASYNC or SND_LOOP);
        replique:=6;
        labelDialogue.width:=0;
        labelDialogue.visible:=true;
        timerDialogue.enabled:=true;
      end;
    end;
  7000:                //Si freePlay est choisi, on continue.
    begin
      if freePlay then
      begin
        tempsEnnemi:=30;
        ennemiSpeed1:=6;
        ennemiSpeed2:=5;
        ennemiSpeed3:=7;
        tempsDeTirEnnemi:=50;
      end;
    end;
  8000:
    begin
      if freePlay then   //Jusqu'à que cela devienne quasi impossible.
      begin
        tempsEnnemi:=20;
        ennemiSpeed1:=8;
        ennemiSpeed2:=8;
        ennemiSpeed3:=8;
        tempsDeTirEnnemi:=30;
      end;
    end;
  9000:
    begin
      tempsEnnemi:=20;
      ennemiSpeed1:=9;
      ennemiSpeed2:=9;
      ennemiSpeed3:=9;
      tempsDeTirEnnemi:=25;
    end;
  10000:
    begin
      tempsEnnemi:=15;
      ennemiSpeed1:=10;
      ennemiSpeed2:=10;
      ennemiSpeed3:=10;
      tempsDeTirEnnemi:=20;
    end;
  12000:
    begin
      tempsEnnemi:=10;
      ennemiSpeed1:=10;
      ennemiSpeed2:=10;
      ennemiSpeed3:=10;
      tempsDeTirEnnemi:=15;
    end;
  14000:
    begin
      tempsEnnemi:=5;
      ennemiSpeed1:=11;
      ennemiSpeed2:=11;
      ennemiSpeed3:=11;
      tempsDeTirEnnemi:=10;
    end;
  16000:
    begin
      tempsEnnemi:=4;
      ennemiSpeed1:=12;
      ennemiSpeed2:=12;
      ennemiSpeed3:=12;
      tempsDeTirEnnemi:=5;
    end;
  end;

  //Algorithme qui gère le boss.
  if bossStage then
  begin
    labelBoss.left:= DynamicShooter.width div 2 - labelBoss.Width div 2;
    //On décrémente le cooldown du boss.
    boss.TirCoolDown:=boss.TirCoolDown-1;
    if(boss.TirCoolDown <= 0) then    //Si le cooldown est plus petit ou égal à zéro.
    begin
      SpawnTir(PATH_TIR_BOSS, 0, 'boss');  //On spawn le tir du boss.
      boss.TirCoolDown:=bossCoolDown;  //On réintialise le boss.TirCoolDown.
    end;

    //Algorithme qui gère les patterns du boss.
    for w:=0 to length(boss.lasers) - 1 do
    begin
      case boss.bossCount of //On change les paramètres du jeux en fonction du score.
      0:
        begin
          bossCoolDown:=10;       //Valeur initiale de bossCoolDown.
          boss.lasers[0].v_x:=4;
          boss.lasers[1].v_x:=-4;
        end;
      2000:
        begin
          //On augmente la fréquence de tir.
          bossCoolDown:=8;
          //On incrémente la vitesse en fonction du temps.
          boss.lasers[w].v_x:=6;
        end;
      4000:
        begin
          bossCoolDown:=5;
          //On replace les lasers pour faire varier la chose.
          boss.lasers[0].image.left:=boss.vaisseau.width div 2 - boss.lasers[0].image.width;
          boss.lasers[1].image.left:=boss.vaisseau.width div 2;
          boss.lasers[0].v_x:=8;
          boss.lasers[0].v_x:=8;
        end;
      6000:
        begin  //Ici la difficulté devient presque impossible.
          bossCoolDown:=2;
          boss.lasers[0].image.left:=0;
          boss.lasers[1].image.left:=boss.vaisseau.width - boss.lasers[1].image.width;
          boss.lasers[0].v_x:=10;
          boss.lasers[1].v_x:=-10;
        end;
      end;
    end;
    //Score qui régit la difficulté du boss.
    boss.bossCount:=boss.bossCount+1;
    //Déplacement des lasers du boss.
    for z:=0 to length(boss.lasers) - 1 do
    begin                                                  //On ajoute la vitesse en x au left.
      boss.lasers[z].image.Left:=boss.lasers[z].image.Left + boss.lasers[z].v_x;
      if boss.lasers[z].image.left < 0 then
      begin
        //Si x est plus petit que 0, alors on est en dehors du form à gauche,
        //il lui faut donc une vitesse positive.
        boss.lasers[z].image.Picture.LoadFromFile(RES + 'boss/lasers1.bmp');
        boss.lasers[z].v_x:= -boss.lasers[z].v_x;
      end
      else if boss.lasers[z].image.left + boss.lasers[z].image.width > DynamicShooter.width then
      begin
        //C'est la vitesse inverse lorsque l'on est en dehors à droite.
        boss.lasers[z].image.Picture.LoadFromFile(RES + 'boss/lasers.bmp');
        boss.lasers[z].v_x:= -boss.lasers[z].v_x;
      end;
    end;


    //Si le cooldown des mines est nul.
    if boss.mineCoolDown = 300 then
      boss.activeMines:=false;

    if boss.mineCoolDown <= 0 then
    begin
      for w:=0 to length(boss.mines) - 1 do
      begin
        //On rends les mines visibles.
        boss.mines[w].imageMine.visible:=true;
        //On leur donne une positiion initiale.
        boss.mines[w].imageMine.top:=boss.vaisseau.top;
        boss.mines[w].imageMine.left:=boss.vaisseau.width div 2;
      end;
      //On les rends actives.
      boss.activeMines:=true;
      boss.mineCoolDown:=400;
    end;

    //Si les mines sont actives.
    if boss.activeMines then
    begin
      for q:=0 to length(boss.mines) - 1 do
      begin
        //On les déplace.
        boss.mines[q].imageMine.top:=boss.mines[q].imageMine.top + boss.mines[q].v_y;
        boss.mines[q].imageMine.left:=boss.mines[q].imageMine.left + boss.mines[q].v_x;
      end;
    end;

    //Si le coolDown est à 200, on arrête de les déplacer.
    if boss.mineCoolDown = 200 then
      boss.activeMines:=false;

    //Si le boss est mort, on retourne au menu principal.
    if (boss.vie <= 0) and not hasBeenKilled then
    begin
      isInMenus:=true;
      boss.vie:=-1;
      labelBoss.visible:=false;
      replique:=7;
      labelDialogue.width:=0;
      hasBeenKilled:= true;
    end;

    if hasBeenKilled then
    begin
      joueurs.setVieAt(0,100);
      joueurs.setVieAt(1,100);
      boss.lasers[0].v_x:=0;
      boss.lasers[1].v_x:=0;
      for we:=0 to tirsBoss.NumberElement - 1 do
      begin
        tirsBoss.getImageAt(we).visible:=false;
      end;
      for wo:=0 to length(boss.mines) - 1 do
      begin
        boss.mines[wo].imageMine.visible:=false;
      end;
      wait:=wait + 1;
    end;

  end;

  if wait > 340 then
  begin
    emptyScreen();
    menuPrincipal();
  end;
  //On incrémente le score à chaque cycle du timer.
  score:= score + 1;
  labelCredits.caption:='Credits:' + intToStr(credits); //On mets à jour les crédits.

  //On place les bonnes textures pour éviter un bug.
  if not characterHasBeenLoaded then
  begin
    for y:=0 to joueurs.nbJoueurs - 1 do
    begin
     joueurs.getImageAt(y).picture.loadFromFile(RES + 'players/player' + intToStr(y+1) + '.bmp');
      refresh();
      //break;
    end;
    characterHasBeenLoaded:=true;
  end;
end;

//Procedure de collision de l'ennemi avec le sol.
procedure TDynamicShooter.EnDehors(tirOuEnnemi: TDynamicArray; genre:string);
var i:integer;
begin
  //On parcour le tableau de l'instance de classe donnée.
  for i:=0 to tirOuEnnemi.NumberElement - 1 do
  begin  //Le genre est un paramètre, car les conditions changent en fonction de l'instance de classe observée.
    //Si l'ennemi est en dehors de l'écran.
    if(genre = 'ennemi') and (tirOuEnnemi.getImageAt(i).top >= DynamicShooter.height) then
    begin
      //On le supprime du tableau.
      tirOuEnnemi.RemoveElement(tirOuEnnemi.getImageAt(i));
      break; //break essentiel, sinon il ne peux plus getImageAt(i) ce qui provoque une erreur.
    end;
    //Si c'est le tir d'un joueur, et qu'il est en dehors de l'éran.
    if(genre = 'tirJoueur') and (tirOuEnnemi.getImageAt(i).top <= -2*tirOuEnnemi.getImageAt(i).height) then
    begin
      //On le supprime du tableau.
      tirOuEnnemi.RemoveElement(tirOuEnnemi.getImageAt(i));
      break; //Break essentiel.
    end;
    //Si c'est le tir d'un ennemi et qu'il est en dehors de l'écran, on le supprime du tableau.
    if(genre = 'tirEnnemi') and (tirOuEnnemi.getImageAt(i).top >= DynamicShooter.Height) then
    begin
      tirOuEnnemi.RemoveElement(tirOuEnnemi.getImageAt(i));
      break;
    end;
    break; //Break essentiel, sans lui avoir trop d'ennemis provoque des erreurs de classe.
  end;
end;

//Procédure pour vider l'écran.
procedure TDynamicShooter.EmptyScreen();
var
  j,k,l,i,z,p,u,o,q:integer;
  invisible:TImage;
begin
  piccard.visible:=false;
  //On rends invisible tout ce qui ne nous intérèsse pas.
  for o:=0 to joueurs.nbJoueurs - 1 do
  begin
    joueurs.getImageAt(o).visible:=false;
    invisible:=joueurs.getImageAt(o);
    joueurs.setImageAt(o,invisible);
  end;

  //On rends les ennemis invisibles.
  for j:= 0 to ennemis.NumberElement - 1 do
  begin
    ennemis.getImageAt(j).visible:=false;
  end;

  //On rends les capcités du joueur invisible.
  for p:=0 to joueurs.nbJoueurs - 1 do
  begin
    joueurs.getLaserAt(p).visible:=false;
    joueurs.getShieldAt(p).image.visible:=false;
    for q:=0 to joueurs.nbMines - 1 do
    begin
      joueurs.getMinesAt(p, q).Visible:=false;
    end;
  end;

  //On rends les tirs ennemis invisibles...
  for k:=0 to tirsEnnemi.NumberElement - 1 do
  begin
    tirsEnnemi.getImageAt(k).visible:=false;
  end;

  //Les tirs du joueur.
  for l:=0 to tirsJoueur.NumberElement - 1 do
  begin
    tirsJoueur.getImageAt(l).visible:=false;
  end;

  //Et du boss... (Si il y en a.)
  for i:=0 to tirsBoss.NumberElement - 1 do
  begin
    tirsBoss.getImageAt(i).visible:=false;
  end;

  //On rends les systèmes à réparer invisibles, si on est mort dans la procédure de réparation.
  if confirmDestruction and dead then
  begin
    for u:=0 to length(SpaceShipSystem) - 1 do
    begin
      SpaceShipSystem[u].image.visible:=false;
    end;
    InterieurVaisseau.visible:=false;
  end;

  //Si c'est le stage du boss, alors on rends les lasers invisibles.
  //On met une condition car ont doit les avoir crées avant de les rendres invisibles.
  if bossStage then
  begin
    for p:= 0 to length(boss.lasers) - 1 do
    begin
      boss.lasers[p].image.visible:=false;
    end;

    //On rends les mines du boss invisibles.
    for z:=0 to length(boss.mines) - 1 do
    begin
      boss.mines[z].imageMine.visible:=false;
    end;
    boss.vaisseau.visible:=false;
  end;

  labelDialogue.visible:=false;

  //On détruit tous les tableaux.
  ennemis.destroyArray();
  tirsBoss.destroyArray();
  tirsJoueur.destroyArray();
  tirsEnnemi.destroyArray();
end;

//Procédure de création de l'arène pour la séquence de réparation.
procedure TDynamicShooter.CreateDestruction();
var
  i,k,o,positionnement:integer;
  newTexture:TImage;
begin
  characterHasBeenLoaded:=false;
  Randomize;
  //Configuration de l'arrière plan.
  InterieurVaisseau.visible:=true;
  InterieurVaisseau.height:=DynamicShooter.height;
  InterieurVaisseau.Width:=DynamicShooter.width;
  InterieurVaisseau.top:=0;
  InterieurVaisseau.left:=0;
  labelCountdown.top:=DynamicShooter.width div 4;
  labelCountdown.left:=DynamicShooter.width div 2 - 100;
  labelCountdown.autoSize:=false;
  labelCountDown.Font.Size:=14;
  labelCountdown.width:=220;
  labelCountdown.Height:=200;
  labelCountdown.Alignment:=taCenter;

  //On rends les labels et images non intéréssantes invisibles.
  bottombar.visible:=false;
  labelScore.visible:=false;
  labelVieJ1.visible:=false;
  labelVieJ2.visible:=false;
  labelCredits.visible:=false;
  labelStore.visible:=false;
  background1.visible:=false;
  background2.visible:=false;

  //Configuration du countdown.
  timeLimit:=initialTimeLimit; //10 secondes, timer à 15 [ms].
  labelCountDown.caption:=intToStr(timeLimit);
  labelCountDown.visible:=true;

  //Configuration du pilote.
  for k:=0 to joueurs.nbJoueurs - 1 do
  begin
    newTexture:=createImage(RES + 'players/pilot' + intToStr(k+1) + '_front.png', 25, 50, true, 0, 0);
    newTexture.Transparent:=true;
    //On mets la texture sur l'objet joueur.
    joueurs.setImageAt(k,newTexture);
    joueurs.getImageAt(k).visible:=true;
    refresh();
    joueurs.getImageAt(k).Picture.loadFromFile(RES + 'players/pilot' + intToStr(k+1) + '_front.png');
    //On configure leur position initiale.
    joueurs.getImageAt(k).left:=DynamicShooter.width div 2 - joueurs.getImageAt(k).width div 2;
    joueurs.getImageAt(k).top:=DynamicShooter.height div 2 - joueurs.getImageAt(k).height div 2;
  end;
                //Entre 0 et 5.
  Randomize;
  destruction:= random(6) + 1;
  SetLength(SpaceShipSystem, destruction);
  //labelTest.caption:=intToStr(length(SpaceShipSystem));

  //J'assigne un spaceShipSystem à chaque case de mon tableau.
  for i:=0 to length(SpaceShipSystem) - 1 do
  begin
    positionnement:=0;
    Randomize;
    degats:=random(100);

    Randomize;
    positionnement:=random(6);
    while positionnement = SpaceShipSystem[i-1].v_x do
    begin
      Randomize;
      positionnement:=random(6);
      if positionnement <> SpaceShipSystem[i-1].v_x then
      begin
        break;
      end;
    end;
    SpaceshipSystem[i]:= CreateSpaceshipSystem(positionnement, degats);
    //Refresh();
  end;

  for o:=0 to joueurs.nbJoueurs - 1 do
  begin
    joueurs.getImageAt(o).Picture.loadFromFile(RES + 'players/pilot' + intToStr(o+1) + '_front.png');
  end;
end;

//Fonction qui crée un Système de bord endomagé, qu'il faut ensuite réparer, le résultat
//est un objet de type TSpaceShipSystem.
function TDynamicShooter.CreateSpaceshipSystem(positionnement:integer; degats:integer): TSpaceShipSystem;
var
  newSystem:TSpaceShipSystem;
  positionsX: array[0..5] of Integer = (150, 400, 150, 400, 150, 400);
  positionsY: array[0..5] of Integer = (100, 100, 300, 300, 500, 500);
begin
  newSystem.image:=createImage(PATH_TERMINAL_2, 50, 50, true, positionsX[positionnement], positionsY[positionnement]);
  Randomize;
  newSystem.v_x:=positionnement;
  newSystem.damage:=degats;     //Dégats.
  Randomize;
  newSystem.image.Visible:=true;
  //Case du tableau aléatoire.
  Result:= newSystem;
end;

//C'est ici que l'on gère ce qui se passe dans la séquence de réparation.
procedure TDynamicShooter.TimerDestructionTimer(Sender: TObject);
var i,l,k,p,o,z,q:integer;
    newTexture:TImage;
begin
  //On déplace les joueurs.
  for o:=0 to joueurs.nbJoueurs - 1 do
  begin
    joueurs.move(o);
  end;
  //Sylvain mono caritas à contribué ce bout de code.
  //On commence cycle avec systemsRepaired = true.
  hasReturned:=true;
  systemsRepaired:=true;
  //On parcoure tous les systèmes détruits.
  for l:=0 to length(SpaceShipSystem) - 1 do
  begin
    //Si un d'entre eux à des dégats non nuls.
    if SpaceShipSystem[l].damage > 0 then
    begin
      hasReturned:=false;
      systemsRepaired:=false;
    end;
  end;

  //Collisions entre le pilote et les systèmes de bord.
  for i:=0 to length(SpaceShipSystem) - 1 do
  begin
    for k:=0 to joueurs.nbJoueurs - 1 do
    begin
      if (GetKeyState(ord(VK_SPACE)) < 0) and Collide(SpaceShipSystem[i].image, joueurs.getImageAt(k)) or
      (GetKeyState(ord(VK_NUMPAD0)) < 0) and Collide(SpaceShipSystem[i].image, joueurs.getImageAt(k)) then
      begin
        if (SpaceShipSystem[i].damage > 0) then
        begin
          //On place le joueur sur l'ordi.
          joueurs.getImageAt(k).BringToFront;
          joueurs.getImageAt(k).Top:=SpaceShipSystem[i].image.top + SpaceShipSystem[i].image.height div 4;
          joueurs.getImageAt(k).left:=SpaceShipSystem[i].image.left + SpaceShipSystem[i].image.width div 4;
          //Réparation du système.
          SpaceShipSystem[i].damage:= SpaceShipSystem[i].damage - 1;

          //Si les dégats sont nuls.
          if SpaceShipSystem[i].damage <= 0 then
          begin
            //On rends le système invisible.
            SpaceShipSystem[i].image.Picture.loadFromFile(PATH_TERMINAL_1);
            SpaceShipSystem[i].image.SendToBack;
            InterieurVaisseau.SendToBack;
            break;
          end;
        end;
      end;
    end;
  end;
  //Si le modulo de la limite de temps est nul, c'est que nous pouvons afficher une seconde.
  if (timeLimit mod 67 = 0) then
  begin
    labelCountDown.caption:=' Time to destruction: ' + #13#10 + intToStr(timeLimit div 67) + '[s]';  //C'est de nouveau à cause de la fréquence de timer de 15 [ms].

    if ((timeLimit div 67) mod 2 = 0) then
    begin
      labelCountDown.Font.Color:=clred;
    end
    else
      labelCountDown.Font.Color:=clwhite;

    labelCountdown.Alignment:=taCenter;
  end;

  //On décrémente la limite de temps.
  timeLimit:=timeLimit - 1;

  //Si les systèmes sont réparés.
  if systemsRepaired then
  begin
    background1.visible:=true;
    background2.visible:=true;
    //On rends pilotes joueurs invisibles.
    for z:=0 to joueurs.nbJoueurs - 1 do
    begin
      joueurs.getImageAt(z).visible:=false;
    end;

    for q:=0 to length(SpaceShipSystem) - 1 do
    begin
      SpaceShipSystem[q].image.visible:=false;
    end;
    //On règle une nouvelle valeur pour le temps, on soustrait une seconde
    //pour la prochaine fois.
    initialTimeLimit:=round(initialTimeLimit/67 - 1);
    initialTimeLimit:=initialTimeLimit*67;

    //On éteint la destruction.
    confirmDestruction:=false;
    joueurs.confirmedDestruction:=false;

    //On rends les images qui nous intérèssent visibles.
    bottombar.visible:=true;
    labelScore.visible:=true;
    labelVieJ1.visible:=true;
    labelVieJ2.visible:=true;
    labelCredits.visible:=true;
    labelStore.visible:=true;
    InterieurVaisseau.visible:=false;
    //On réactive le timer.

    for p:=0 to joueurs.nbJoueurs - 1 do
    begin
      newTexture:=createImage('./ressources/players/player' + intToStr(p+1) + '.bmp', 50, 50, true, DynamicShooter.width div 2 - 25, DynamicShooter.height div 2 - 25);
      newTexture.Stretch:=true;
      newTexture.Transparent:=true;
      joueurs.setImageAt(p,newTexture);
      labelCountDown.visible:=false;
      joueurs.getImageAt(p).Picture.LoadFromFile('./ressources/players/player' + intToStr(p+1) + '.bmp');
    end;
    TimerDestruction.enabled:=false;
    TimerPrincipal.enabled:=true;
    characterHasBeenLoaded:=false;
  end;

  dead:=false;
  if(timeLimit = 0) then
  begin
    background1.visible:=true;
    background2.visible:=true;
    //On se sert de dead pour savoir si il faut également rendre invisible ou pas
    //les TSpaceShipSystems dans la procédure EmptyScreen();
    dead:=true;
    isInMenus:=true;
    joueurs.getImageAt(0).top:= -2000;
    joueurs.getImageAt(0).visible:=false;
    //On vide l'écran.
    EmptyScreen();
    //On affiche le menu principal.
    menuPrincipal();
  end;
end;

// Affiche les scores dans la liste des scores
procedure TDynamicShooter.DisplayScore();
var
  j: integer;
begin
  scoreboard.Clear; // Nettoye les entrée du mémo
  // Parcours tous les scores pour les afficher dans la liste des scores
  for j:= 0 to length(scores) - 1 do
    scoreboard.Lines.Add(Scores[j].pseudo + ' - ' + IntToStr(Scores[j].score));
end;

//Sauvegarde des scores.
procedure TDynamicShooter.SaveScore();
var
  newScore: TScore;
  fScore: File of TScore; // Variable de type fichier contenant des recordes de score
  j, e: integer;
  tmpScore : TScore;
begin           //crée une variable qui change en fonction de l'input pour le string.
  newScore.pseudo:= pseudo;  // Assigne le pseudo a newScore.pseudo
  newScore.score:= score; // Assigne difficulté a newScore.score
                    //length tableau scores
  for j:= 0 to length(scores) - 1 do
  begin
    if (scores[j].score < newScore.score) then
    begin
      e:= length(Scores) - 1;
      // Décalage des scores
      while e <> j do
      begin
        tmpScore:= Scores[e];
        Scores[e]:= Scores[e - 1];
        if e <> j then
          Scores[e-1]:= tmpScore;

        dec(e); // Je commence à la fin, donc je décrémente
      end;

      Scores[j]:= newScore;  // Assigne le nouveau score
      break;
    end;
  end;

  AssignFile(fScore, FICHIER_SCORE); // Assigne le FICHIER_SCORE à fscore

  try
    ReWrite(fScore); // Réécrit le fichier des scores
    // Parcours tous les scores pour les ajouter au fichier
    for j:= 0 to length(scores) - 1 do
    begin
      Write(FScore, scores[j]); // Ecrit dans le fichier
    end;
  finally
    CloseFile(FScore); // Ferme le fichier
  end;
end;

//Chargement des scores depuis le fichier
procedure TDynamicShooter.ChargerScore();
var
  score : TScore;
  fileScore : file of TScore; // Variable de type fichier contenant des recordes de score
  j: integer;
begin
  AssignFile(fileScore, FICHIER_SCORE); // Assigne le fichier FICHIER_SCORE (regarde tes constantes) à la variable fileScore

  try
    Reset(fileScore); // Ouverture du fichier
    j:= 0;
    while not EOF(fileScore) do // Lit jusqu'à la fin du fichier
    begin
      Seek(fileScore, j); // Déplace le curseur à la position j dans le fichier fileScore
      Read(fileScore, score); // Lecture de la ligne (récupère un TScore)
      scores[j]:= score; // Ajoute mon score dans mon tableau de score
      j:= j + 1;
    end;
  finally
    closeFile(fileScore); // Je ferme mon ficher fileScore
  end;
end;

end.



















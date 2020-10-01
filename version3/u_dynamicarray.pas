{**************************************************************
* Description : Simple class to manage a Dynamic Array.       *
* Author      : 4|> (Alan Devaud)                             *
* Date        : 10.01.2018                                    *
* Version     : 1.0                                           *
***************************************************************}
unit U_DynamicArray;    //unit unité ou on a du code.

{$mode objfpc}{$H+}

interface

uses  //unités que mon unit utilise.
  Classes, SysUtils, ExtCtrls;

type
  TVaisseaux = Record
    Vie:integer;
    image:TImage;
    v_y:integer;
    v_x:integer;
    direction:integer;
  end;

  TDynamicArray = Class  //on crée un type qui est une classe.
    private                        //le privé s'accède que sur cette classe.
      AnArray: array of TVaisseaux;
      CountElement: Integer;
    public      //On accède ceci directement depuis le form, c'est publique, partout.
      function GetSize() : integer;
      property Size: Integer read GetSize;  //ceci permet de lire une propriété privée. Public size is the value of private GetSize.
      property NumberElement : Integer read CountElement;
      procedure AddElement(NewElement: TVaisseaux); //Ajoute un élément au tableau dynamique.
      procedure RemoveElement(ElementToRemove: TImage);
      function getImageAt(index: integer) : TImage;
      function getVieAt(index: integer) : integer;
      function getVyAt(index:integer): integer;
      function getVxAt(index:integer):integer;
      procedure setVxAt(index:integer; newVx:integer);
      function getDirectionAt(index:integer):integer;
      procedure setVieAt(newVie, index : integer);
      procedure setImageAt(index: integer; image: TImage);
      constructor Create(); overload;//au moment de la création, j'exécute ce qui est dans le constructeur. On crée tout depuis rien. (Ce n'est pas un onCreate.)
      destructor Destroy; override;
      procedure destroyArray();
  end;

const
  DEFAULT_SIZE: integer = 1;

implementation

// Create a new Dynamique Array Constructors permet d'allocer la mémoire pour.
constructor TDynamicArray.Create;
begin
  inherited;
  SetLength(Self.AnArray, DEFAULT_SIZE); //attribut self permet de dire que l'on prends la variable de la classe, et non celle locale, self permet d'accéder à la globale.
  self.CountElement:= 0;
end;

//Destructor permet de la détruire.
destructor TDynamicArray.Destroy;
begin
  //Fonction héritée qui est récupérée sur le parent.
  Inherited;
end;

// Return the array size
function TDynamicArray.GetSize() : integer;
begin
         //Self accède à la propriété de la classe.
  Result:= self.CountElement;  //ceci est égal à le résultat de la fonction que l'on peut accéder par l'attribut public size.
end;

function TDynamicArray.getVyAt(index:integer): integer;
begin
  Result:= AnArray[index].v_y;
end;

function TDynamicArray.getVxAt(index:integer):integer;
begin
  Result:= AnArray[index].v_x;
end;

procedure TDynamicArray.setVxAt(index:integer; newVx:integer);
begin
  AnArray[index].v_x:=newVx;
end;

function TDynamicArray.getDirectionAt(index:integer):integer;
begin
  Result:=AnArray[index].direction;
end;

// Add a new Element in the array.
procedure TDynamicArray.AddElement(NewElement: TVaisseaux);
begin
  //On augmente la taille du tableau.
  SetLength(AnArray, Length(AnArray) + 1);
  //On ajoute l'élément à la dernière case du tableau, qui vient d'être crée.
  self.AnArray[self.CountElement]:= NewElement;
  //On incrémente le nombre d'éléments dans le tableau.
  Inc(Self.CountElement);
end;

//Remove the specified item.
procedure TDynamicArray.RemoveElement(ElementToRemove: TImage);
//on trouve ce qu'il faut supprimer, on décale ce qu'il faut garder et on enlève la case en trop, donc le tableau devient plus petit.
var
  j: integer;
begin
    //je vérifie que j+1 soit toujours inférieur à la taille de mon tableau pour ne pas accéder au néant.
    for j:= 0 to Length(AnArray) - 1 do
    begin                                                                      // 0  1  2  3  4  5  6   CountElement = 7
        //1.) on décale vers l'avant, et on supprime la case d'avant.          //[a][b][c][d][e][f][g]
        AnArray[j]:= AnArray[j+1];                                              //1.)
    end;                                                                       // 0  1  2  3  4  5  6   CountElement = 7
  //Détruire l'image dont on veut se débarasser, et libérer la mémoire.        //[b][c][d][e][f][g][g]
  elementToRemove.Destroy;                                                     //3.)
  //On modifie le nombre d'elements. 2.)                                       // 0  1  2  3  4  5      CountElement = 6
  self.CountElement:= self.CountElement - 1;                                   //[b][c][d][e][f][g]
  //On change la taille du tableau, qui devient plus petit.  3.)
  SetLength(AnArray, self.CountElement);
end;

//Fonction qui nous donne l'image d'une certaine case que l'on appelle avec DynamicArray.getImageAt(i).
function TDynamicArray.getImageAt(index: integer) : TImage;
begin
  Result:= AnArray[index].image;
end;

//Procedure qui nous permet d'assigner une certaine image d'une certaine case à une nouvelle certaine image.
procedure TDynamicArray.setImageAt(index: integer; image: TImage);
begin
  AnArray[index].image:= image;
end;

//Fonction qui nous rends la vie des vaisseaux à un moment spécifique.
function TDynamicArray.getVieAt(index: integer) : integer;
begin
  Result:= AnArray[index].vie;
end;

//Procedure qui nous permet de régler la vie d'une case d'un DynamicArray (tirs1, ennemis1...)
procedure TDynamicArray.setVieAt(newVie, index : integer);
begin
  AnArray[index].vie:= newVie;
end;

//Procédure qui détruit les entrées de mon array et le vide complètement.
procedure TDynamicArray.destroyArray();
var
  i: integer;
begin
  for i:= 0 to CountElement - 1 do
  begin
      self.AnArray:= nil;
  end;
  SetLength(AnArray, 0);
  CountElement:= 0;
end;

end.



































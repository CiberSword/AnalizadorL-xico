%{
/*
Facultad de Ingeniería UNAM
Compiladores
Grupo: 5
Primer programa - Analizador Lexico
Integrantes: 
- Becerril Olivar Axel Daniel
- Jarquín Lopez Daniel

Descripción:
Elaborar un analizador léxico en lex/flex que reconozca los componentes léxicos de un programa de entrada.
*/

// Declaracion de archivos de salida donde se guardaran los tokens y las tablas de literales (cadenas, reales, identificadores)

FILE *archSal;
FILE *archCadenas;
FILE *archReales;
FILE *archIds;
FILE *archErrores;

// Declaración de las estructuras para cada elemento

struct token {   
  int clase;          
  char* valor;      
};

struct cadena {   
  int posicion;          
  char* valor;      
};

struct numReal {   
  int posicion;          
  char* valor;      
};

struct palReservada{
  int posicion;
  char* valor;
};

struct identificador {   
  int posicion;          
  char* nombre;
  int tipo;      
};

// Inicializacion de los arreglos de estructuras

struct token *Tokens;
struct cadena *Tabla_Cadenas;
struct numReal *Tabla_NumReales;
struct identificador *Tabla_Ids;

struct palReservada Reservadas[11];

// Inicializacion especifica para la tabla de palabras reservadas

struct palReservada Reservadas[11] = {
  {0,"ent"},
  {1,"finsi"},
  {2,"haz"},
  {3,"mientras"},
  {4,"large"},
  {5,"para"},
  {6,"real"},
  {7,"regresa"},
  {8,"si"},
  {9,"simb"},
  {10,"sino"}
};

// Variables indice para las tablas con arreglos dinamicos, tambien se utilizan para ajustar su tamanio 

int posCadenas = 0;
int posNumReales = 0;
int posIds = 0;
int posTokens = 0;

// Variable buffer para la conversion de variables a cadenas

char buffer[20];

%}

ident [a-z][a-z_]+
simbEsp \(|\)|\{|\}|\;|\,|\[|\]
opRel =|"/="|">="|\>|\<|"<="
opAsig "->"
palRes "ent"|"finsi"|"haz"|"mientras"|"large"|"para"|"real"|"regresa"|"si"|"simb"|"sino"
opArit \+|\-|\*|\/|\%
dig [0-9]
entero ^[0-9]+
octal 0([0-7]){2}
digHex [0-9A-Fa-f]
hexDec 0(x|X){digHex}+
consChar \'[^\']\'
consString \"[^\"]*\"
consReal {dig}+\.{dig}+
errorId ^_.*|[0-9]+.*|[A-Z]+.*
errorCadena \"[^\n\"]*\n[^\n\"]*\"|\"[^\n\"]*\\n[^\n\"]*\"
errorReal ^\.[0-9]+$

%%

{errorCadena} fprintf(archErrores, "Error Lexico - Cadena incorrecta: %s\n", yytext);
{consString} insertarCadena(yytext);
{palRes} insertarPalReservada(yytext);
{ident} insertarId(yytext);
{octal} insertarToken(6, yytext);
{hexDec} insertarToken(6, yytext);
{entero} insertarToken(6, yytext);
{consReal} insertarNumReal(yytext);
{simbEsp} insertarToken(1, yytext);
{opRel} insertarToken(2, yytext);
{opAsig} insertarToken(3, yytext);
{opArit} insertarToken(5, yytext);
{consChar} insertarCaracter(yytext);
{errorReal} fprintf(archErrores, "Error Lexico - Numero Real incorrecto: %s\n", yytext);
{errorId} fprintf(archErrores, "Error Lexico - Identificador incorrecto: %s\n", yytext);

%%

// Funcion principal que recibe un archivo de entrada

main(int argc, char *argv[])
{

// Asignacion de memoria a los arreglos dinamicos, comienzan con tamanio de 1 elemento

Tokens = (struct token*) malloc((posTokens+1) * sizeof(struct token));
Tabla_Cadenas = (struct cadena*) malloc((posCadenas+1) * sizeof(struct cadena));
Tabla_NumReales = (struct numReal*) malloc((posNumReales+1) * sizeof(struct numReal));
Tabla_Ids = (struct identificador*) malloc((posIds+1) * sizeof(struct identificador));

// Apertura del archivo de entrada

yyin = fopen(argv[1],"r");

// Creacion de los archivos de salida

archSal = fopen("Tokens.txt","w");
archCadenas = fopen("Tabla_Cadenas.txt","w");
archReales = fopen("Tabla_Reales.txt","w");
archIds = fopen("Tabla_Identificadores.txt","w");
archErrores = fopen("Errores.txt","w");

// Uso de funcion yylex() para aplicar las reglas definidas en la seccion anterior

yylex();

// Cierre de los archivos de salida

fclose(archSal);
fclose(archCadenas);
fclose(archReales);
fclose(archIds);
fclose(archErrores);
}

// Funcion que realiza las inserciones de tokens, recibe un numero de clase y un valor
// el cual puede ser un simbolo, un entero o una posicion de una tabla de literales

void insertarToken(int numClase, char *dato){
    Tokens[posTokens].clase = numClase;
    Tokens[posTokens].valor = dato;
    fprintf(archSal, "(%i,%s)\n", numClase, dato);
    posTokens++;
    Tokens = (struct token*)realloc(Tokens, (posTokens+1) * sizeof(struct token));
}

// Funcion especial para insertar cadenas en los tokens y en su tabla de literales

void insertarCadena(char *dato){
    Tabla_Cadenas[posCadenas].posicion = posCadenas;
    Tabla_Cadenas[posCadenas].valor = dato;
    sprintf(buffer, "%d", posCadenas);
    insertarToken(7,buffer);
    fprintf(archCadenas, "(%i,%s)\n", posCadenas, dato);
    posCadenas++;
    Tabla_Cadenas = (struct cadena*)realloc(Tabla_Cadenas, (posCadenas+1) * sizeof(struct cadena)); 
};

// Funcion especial para insertar numeros reales en los tokens y en su tabla de literales

void insertarNumReal(char *dato){
    Tabla_NumReales[posNumReales].posicion = posNumReales;
    Tabla_NumReales[posNumReales].valor = dato;
    sprintf(buffer, "%d", posNumReales);
    insertarToken(9,buffer);
    fprintf(archReales, "(%i,%s)\n", posNumReales, dato);
    posNumReales++;
    Tabla_NumReales = (struct numReal*)realloc(Tabla_NumReales, (posNumReales+1) * sizeof(struct numReal)); 
};

// Funcion especial para insertar identificadores en los tokens y en su tabla de literales

void insertarId(char *dato){
    Tabla_Ids[posIds].posicion = posIds;
    Tabla_Ids[posIds].nombre = dato;
    Tabla_Ids[posIds].tipo = -1;
    sprintf(buffer, "%d", posIds);
    insertarToken(0,buffer);
    fprintf(archIds, "(%i,%s,%i)\n", posIds, dato, Tabla_Ids[posIds].tipo);
    posIds++;
    Tabla_Ids = (struct identificador*)realloc(Tabla_Ids, (posIds+1) * sizeof(struct identificador)); 
};

// Funcion especial para insertar palabras reservadas, realiza una iteracion en la tabla predefinida
// de palabras reservadas y envia a insertarToken() el indice correspondiente a la palabra encontrada

void insertarPalReservada(char *dato){
    int iterador = 0;
    for (iterador;iterador <=10;iterador++){
      if (strcmp(dato,Reservadas[iterador].valor) == 0){
        sprintf(buffer, "%d", iterador);
        insertarToken(4,buffer);
      }
    }
}

// Funcion que quita los apostrofes a los caracteres encontrados por la expresion regular 
// antes de enviarlos a insertarToken()
// Ejemplo: '@' -> @

void insertarCaracter(char *dato){
  sprintf(buffer, "%c", dato[1]);
  insertarToken(8,buffer);
}
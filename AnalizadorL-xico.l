%{
/* Programa que lee un programa y hace el
reconocimiento de identificadores,
palabras reservadas y enteros de un
lenguaje x
*/
FILE *archSal;
%}
ident [a-z_]{2,}
simbEsp \(|\)|\{|\}|\;|\,|\[|\]
opRel =|"/="|">="|\>|\<|"<="
opAsig "->"
palRes "ent"|"finsi"|"haz"|"mientras"|"large"|"para"|"real"|"regresa"|"si"|"simb"|"sino"
opArit \+|\-|\*|\/|\%

dig [0-9]
entero {dig}+
octal 0([0-7]){2}
digHex [0-9A-Fa-f]
hexDec 0(x|X){digHex}+

consChar \'[^\']\'
consString \"[^\"]*\"
consReal {dig}+\.{dig}+

%%
{consString} fprintf(archSal," %s es una cadena\n", yytext);
{palRes} fprintf(archSal," %s es una palabra reservada\n", yytext);
{ident} fprintf(archSal," %s es un identificador\n", yytext);
{octal} fprintf(archSal," %s es un numero octal\n", yytext);
{hexDec} fprintf(archSal," %s es un numero hexadecimal\n", yytext);
{entero} fprintf(archSal," %s es un numero entero\n", yytext);
{consReal} fprintf(archSal," %s es un numero real\n", yytext);
{simbEsp} fprintf(archSal," %s es un simbolo especial\n", yytext);
{opRel} fprintf(archSal," %s es un operador relacional\n", yytext);
{opAsig} fprintf(archSal," %s es un operador de asignación\n", yytext);
{opArit} fprintf(archSal," %s es un operador aritmetico\n", yytext);
{consChar} fprintf(archSal," %s es un simbolo\n", yytext);
%%
main(int argc, char *argv[])
{
yyin = fopen(argv[1],"r");
archSal = fopen("salida.txt","w");
yylex();
fclose(archSal);
}


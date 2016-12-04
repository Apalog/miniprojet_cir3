%{
  // Library
  #include <iostream>
  #include <fstream>
  #include <cstdlib>
  #include <cstdio>
  #include <cmath>
  #include <stack>
  #include <vector>
  #include <string>
  #include <map>
  using namespace std;

  // out c++
  extern "C" int yylex();
  extern "C" int yyparse();
  extern "C" FILE *yyin;
  //error
  void yyerror(const char *s);
  void add(string);
  void add0();
  double eval(vector<int>&,double);
  void calcul(double,double,double);
  double value;
  string namE;
  double interval[3];
  vector<int> postfixee;
  vector<double> values;
  map<string,vector<int> > vectorPost_fixe;
  map<string,vector<double> > vectorValues;
%}

%union {
  int ival;
  double fval;
  char* sval;
}

%type <fval> expression
%type <fval> variable
%type <fval> operateur
%type <fval> numbers

%token <fval> number
%token <sval> name
%token X
%token SIN COS TAN SINH COSH TANH ASIN ACOS ATAN ABS
%token LOG EXP LN
%token SQRT
%token e
%token PI

%left '-' '+'
%left '/' '*'
%left '^'
%left NEGATIF

%%
input :| input line;
line : '\n'| expression '\n' {add0();}
;

numbers : '-' number %prec NEGATIF {$$ = -1*$2;} | number {$$ = $1;}
;

expression : number {postfixee.push_back(number); values.push_back($1);}
              | operateur
              | variable {postfixee.push_back(X); values.push_back(0);}
            //  | name '=' expression {namE = $1; add(namE);}
              | PI {$$ = 3.1415926; postfixee.push_back(PI); values.push_back(0);}
              | e {$$ = 2.718281828; postfixee.push_back(e); values.push_back(0);}
              | expression '+' expression {postfixee.push_back('+'); values.push_back(0);}
              | expression '-' expression {postfixee.push_back('-'); values.push_back(0);}
              | expression '*' expression {postfixee.push_back('*'); values.push_back(0);}
              | expression '/' expression {postfixee.push_back('/'); values.push_back(0);}
              | '(' expression ')' '^' expression {postfixee.push_back('^'); values.push_back(0); }

              | '-' expression %prec NEGATIF {postfixee.push_back( NEGATIF); values.push_back(0);}
              | '(' expression ')'  { postfixee.push_back( $2); }
              | '|' expression '|'  { postfixee.push_back( ABS); values.push_back(0);}
              | '['numbers numbers numbers']' {interval[0] = $2; interval[1] = $3; interval[2]= $4;}
                    // [min max pas]
;
operateur :   SIN  '('expression')' { postfixee.push_back(SIN);   values.push_back(0);}
              | COS  '('expression')' { postfixee.push_back(COS);   values.push_back(0);}
              | TAN  '('expression')' { postfixee.push_back(TAN);   values.push_back(0);}
              | ASIN '('expression')' { postfixee.push_back(ASIN);  values.push_back(0);}
              | ACOS '('expression')' { postfixee.push_back(ACOS);  values.push_back(0);}
              | ATAN '('expression')' { postfixee.push_back(ATAN);  values.push_back(0);}
              | SINH '('expression')' { postfixee.push_back(SINH);  values.push_back(0);}
              | COSH '('expression')' { postfixee.push_back(COSH);  values.push_back(0);}
              | TANH '('expression')' { postfixee.push_back(TANH);  values.push_back(0);}
              | SQRT '('expression')' { postfixee.push_back(SQRT);  values.push_back(0);}
              | LN   '('expression')' { postfixee.push_back(LN);    values.push_back(0);}
              | LOG  '('expression')' { postfixee.push_back(LOG);   values.push_back(0);}
              | EXP  '('expression')' { postfixee.push_back(EXP);   values.push_back(0);}
;
variable : X {$$ = value;}
%%

int main(int argc, char** argv) {
  yyparse();
    double min = interval[0];
    double max = interval[1];
    double pas = interval[2];
    calcul(min,max,pas);
  return 0;
}

void calcul(double min, double max, double pas){
  ofstream fichier("fichierResultat.txt", ios::app);  // ouverture en écriture sans effacement
  map<string, vector<int> >::iterator it;
  if(fichier){
    for(it= vectorPost_fixe.begin() ;it != vectorPost_fixe.end();++it){
      for(double val= min ; val<= max ; val+=pas){
        fichier << val << endl;
        double tmp = eval(it->second,val);
        if (tmp == tmp){
          fichier << tmp <<endl;
          cout << val <<" = x y= "<<tmp<<endl;
        }
      }
	    fichier << "#" <<endl;
    }
  fichier.close();
  }
}

double eval(vector<int> &pF,double j){
  std::stack<double> pile;
  int valMax;
  double tmp1=0, tmp2=0;
  for(valMax = 0; valMax < pF.size() ; valMax++){
    if(pF[valMax] == number ) {pile.push(values[valMax]);}
    if(pF[valMax] == PI )     {pile.push(PI);}
    if(pF[valMax] == e )      {pile.push(e);}

    if(pF[valMax] == '+' )  {tmp2 = pile.top(); pile.pop();
                                  tmp1 = pile.top(); pile.pop();
                                  pile.push(tmp1 + tmp2);}
    if(pF[valMax] == '-' )  {tmp2 = pile.top(); pile.pop();
                                  tmp1 = pile.top(); pile.pop();
                                  pile.push(tmp1 - tmp2);}
    if(pF[valMax] == '*' )  {tmp2 = pile.top(); pile.pop();
                                   tmp1 = pile.top(); pile.pop();
                                   pile.push(tmp1 * tmp2);}
    if(pF[valMax] == '/' )  {tmp2 = pile.top(); pile.pop();
                                  tmp1 = pile.top(); pile.pop();
                                  pile.push(tmp1 / tmp2);}
    if(pF[valMax] == '^' )  {tmp2 = pile.top(); pile.pop();
                                  tmp1 = pile.top(); pile.pop();
                                  pile.push(pow(tmp1,tmp2));}
    if(pF[valMax] == SQRT ) {tmp1 = pile.top(); pile.pop();
                                  pile.push(sqrt(tmp1));}
    if(pF[valMax] == SIN )  {tmp1 = pile.top(); pile.pop();
                                  pile.push(sin(tmp1));}
    if(pF[valMax] == COS )  {tmp1 = pile.top();pile.pop();
                                  pile.push(cos(tmp1));}
    if(pF[valMax] == TAN )  {tmp1 = pile.top();pile.pop();
                                  pile.push(tan(tmp1));}
    if(pF[valMax] == SINH ) {tmp1 = pile.top(); pile.pop();
                                  pile.push(sinh(tmp1));}
    if(pF[valMax] == LN )   {tmp1 = pile.top();pile.pop();
                                 pile.push(log(tmp1));}
    if(pF[valMax] == LOG )  {tmp1 = pile.top();pile.pop();
                                pile.push(log10(tmp1));}
    if(pF[valMax] == COSH ) {tmp1 = pile.top();pile.pop();
                                  pile.push((exp(tmp1)+exp(-tmp1))/2);}
    if(pF[valMax] == TANH ) {tmp1 = pile.top();pile.pop();
                                  pile.push(tanh(tmp1));}
    if(pF[valMax] == ASIN ) {tmp1 = pile.top(); pile.pop();
                                  pile.push(asin(tmp1));}
    if(pF[valMax] == ACOS ) {tmp1 = pile.top();pile.pop();
                                  pile.push(acos(tmp1));}
    if(pF[valMax] == ATAN ) {tmp1 = pile.top();pile.pop();
                                  pile.push(atan(tmp1));}
    if(pF[valMax] == EXP )  {tmp1 = pile.top();pile.pop();
                                  pile.push(exp(tmp1));}
    if(pF[valMax] == X)     {pile.push(j);}
  }
  tmp1 = 0;
  tmp1 = pile.top();
  return tmp1;
}

void add(string j){
  vectorPost_fixe[j]= postfixee;
  vectorValues[j] = values;
}

void add0(){
  string a_to_z[25] = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","Y","Z"};
  int random = rand() % 25;
  string j = a_to_z[random];
  vectorPost_fixe.insert(pair<string, vector<int> >(j,postfixee));
  vectorValues.insert(pair<string,vector<double> >(j,values));
}

void yyerror(const char *s) {
	std::cout << "EEK, parse error!  Message: " << s << std::endl;
	exit(-1);
}

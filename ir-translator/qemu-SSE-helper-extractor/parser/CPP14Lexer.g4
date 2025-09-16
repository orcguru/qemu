lexer grammar CPP14Lexer;

IntegerLiteral:
	DecimalLiteral Integersuffix?
	| OctalLiteral Integersuffix?
	| HexadecimalLiteral Integersuffix?
	| BinaryLiteral Integersuffix?;

CharacterLiteral:
	('u' | 'U' | 'L')? '\'' Cchar+ '\'';

FloatingLiteral:
	Fractionalconstant Exponentpart? Floatingsuffix?
	| Digitsequence Exponentpart Floatingsuffix?;

StringLiteral:
	Encodingprefix?
    (Rawstring
	|'"' Schar* '"'
	|'"' Schar* '"' Whitespace* Colon Colon Colon Whitespace* '"' Schar* '"'
	|'"' Schar* '"' Whitespace* '"' Schar* '"'
	|'"' Schar* '"' Whitespace* '"' Schar* '"' Whitespace* '"' Schar* '"'
	|'"' Schar* '"' Whitespace* '"' Schar* '"' Whitespace* '"' Schar* '"' Whitespace* '"' Schar* '"'
	|'"' Schar* '"' Whitespace* '"' Schar* '"' Whitespace* '"' Schar* '"' Whitespace* '"' Schar* '"' Whitespace* '"' Schar* '"'
	|'"' Schar* '"' Whitespace* '\n' Whitespace* '"' Schar* '"'
	|'"' Schar* '"' Whitespace* '\n' Whitespace* '"' Schar* '"' '\n' Whitespace* '"' Schar* '"'
	|'"' Schar* '"' Whitespace* '\n' Whitespace* '"' Schar* '"' '\n' Whitespace* '"' Schar* '"' '\n' Whitespace* '"' Schar* '"'
	|'"' Schar* '"' Whitespace* '\n' Whitespace* '"' Schar* '"' '\n' Whitespace* '"' Schar* '"' '\n' Whitespace* '"' Schar* '"' '\n' Whitespace* '"' Schar* '"')
        | Encodingprefix? 'R' Rawstring2;

BooleanLiteral: False_ | True_;

PointerLiteral: Nullptr;

UserDefinedLiteral:
	UserDefinedIntegerLiteral
	| UserDefinedFloatingLiteral
	| UserDefinedStringLiteral
	| UserDefinedCharacterLiteral;

MultiLineMacro:
	'#' (~[\n]*? '\\' '\r'? '\n')+ ~ [\n]+ -> channel (HIDDEN);

Directive: '#' ~ [\n]* -> channel (HIDDEN);
/*Keywords*/

Alignas: 'alignas';

Alignof: 'alignof' | '__alignof__';

Asm: 'asm' | '__asm' | '__asm__';

Auto: 'auto';

Bool: 'bool';

Break: 'break';

Case: 'case';

Catch: 'catch';

Char: 'char';

Char16: 'char16_t';

Char32: 'char32_t';

Const: 'const';

Constexpr: 'constexpr';

Const_cast: 'const_cast';

Continue: 'continue';

Decltype: 'decltype';

Decltype2: '__decltype';

Default: 'default';

Delete: 'delete';

Do: 'do';

Double: 'double';

Dynamic_cast: 'dynamic_cast';

Else: 'else';

Enum: 'enum';

Explicit: 'explicit';

Export: 'export';

Extern: 'extern';

Extension: '__extension__';

//DO NOT RENAME - PYTHON NEEDS True and False
False_: 'false';

Final: 'final';

Float: 'float';

For: 'for';

Friend: 'friend';

Goto: 'goto';

If: 'if';

Inline: 'inline';

Inline2: '__inline';

Int: 'int';

Long: 'long';

Mutable: 'mutable';

Namespace: '__No_Such_Namespace__';

New: 'new';

Noexcept: 'noexcept';

Nullptr: 'nullptr';

Operator: 'operator';

OperatorSpecial1: 'operator""s';

OperatorSpecial2: 'operator""h';

OperatorSpecial3: 'operator""min';

OperatorSpecial4: 'operator""ms';

OperatorSpecial5: 'operator""us';

OperatorSpecial6: 'operator""ns';

Override: 'override';

Protected: 'protected';

Public: 'public';

Register: 'register';

Reinterpret_cast: 'reinterpret_cast';

Return: 'return';

Restrict: '__restrict' | '__restrict__';

Short: 'short';

Signed: 'signed';

Sizeof: 'sizeof';

Static: 'static';

Static_assert: 'static_assert' | '_Static_assert';

Static_cast: 'static_cast';

Struct: 'struct';

Switch: 'switch';

Template: 'template';

Thread_local: 'thread_local';

Throw: 'throw';

//DO NOT RENAME - PYTHON NEEDS True and False
True_: 'true';

Try: 'try';

HackBuildin1: '__builtin_types_compatible_p';

HackBuildin2: '__builtin_offsetof';

HackBuildin3: '__builtin_va_arg';

Typedef: 'typedef';

Typeof: '__typeof__' | '__typeof' | 'typeof' | '__typeof_unqual__';

Typeid_: 'typeid';

Typename_: 'typename';

Union: 'union';

Unsigned: 'unsigned';

Using: 'using';

Virtual: 'virtual';

Void: 'void';

Volatile: 'volatile' | '__volatile__';

Wchar: 'wchar_t';

While: 'while';
/*Operators*/

LeftParen: '(';

RightParen: ')';

LeftBracket: '[';

RightBracket: ']';

LeftBrace: '{';

RightBrace: '}';

Plus: '+';

Minus: '-';

Star: '*';

Div: '/';

Mod: '%';

Caret: '^';

And: '&';

Or: '|';

Tilde: '~';

Not: '!' | 'not';

Assign: '=';

Less: '<';

Greater: '>';

PlusAssign: '+=';

MinusAssign: '-=';

StarAssign: '*=';

DivAssign: '/=';

ModAssign: '%=';

XorAssign: '^=';

AndAssign: '&=';

OrAssign: '|=';

LeftShiftAssign: '<<=';

RightShiftAssign: '>>=';

Equal: '==';

NotEqual: '!=';

LessEqual: '<=';

GreaterEqual: '>=';

AndAnd: '&&' | 'and';

OrOr: '||' | 'or';

PlusPlus: '++';

MinusMinus: '--';

Comma: ',';

ArrowStar: '->*';

Arrow: '->';

Question: '?';

Colon: ':';

Doublecolon: '::';

Triplecolon: ':::';

Semi: ';';

Dot: '.';

DotStar: '.*';

Ellipsis: '...';

fragment Hexquad:
	HEXADECIMALDIGIT HEXADECIMALDIGIT HEXADECIMALDIGIT HEXADECIMALDIGIT;

fragment Universalcharactername:
	'\\u' Hexquad
	| '\\U' Hexquad Hexquad;

Identifier:
	/*
	 Identifiernondigit | Identifier Identifiernondigit | Identifier DIGIT
	 */
	Identifiernondigit (Identifiernondigit | DIGIT)*;

fragment Identifiernondigit: NONDIGIT | Universalcharactername;

fragment NONDIGIT: [a-zA-Z_];

fragment DIGIT: [0-9];

DecimalLiteral: NONZERODIGIT ('\''? DIGIT)*;

OctalLiteral: '0' ('\''? OCTALDIGIT)*;

HexadecimalLiteral: ('0x' | '0X') HEXADECIMALDIGIT (
		'\''? HEXADECIMALDIGIT
	)*;

BinaryLiteral: ('0b' | '0B') BINARYDIGIT ('\''? BINARYDIGIT)*;

fragment NONZERODIGIT: [1-9];

fragment OCTALDIGIT: [0-7];

fragment HEXADECIMALDIGIT: [0-9a-fA-F];

fragment BINARYDIGIT: [01];

Integersuffix:
	Unsignedsuffix Longsuffix?
	| Unsignedsuffix Longlongsuffix?
	| Longsuffix Unsignedsuffix?
	| Longlongsuffix Unsignedsuffix?;

fragment Unsignedsuffix: [uU];

fragment Longsuffix: [lL];

fragment Longlongsuffix: 'll' | 'LL';

fragment Cchar:
	~ ['\\\r\n]
	| Escapesequence
	| Universalcharactername;

fragment Escapesequence:
	Simpleescapesequence
	| Octalescapesequence
	| Hexadecimalescapesequence;

fragment Simpleescapesequence:
	'\\\''
	| '\\"'
	| '\\?'
	| '\\\\'
	| '\\a'
	| '\\b'
	| '\\f'
	| '\\n'
	| '\\r'
	| ('\\' ('\r' '\n'? | '\n'))
	| '\\t'
	| '\\v';

fragment Octalescapesequence:
	'\\' OCTALDIGIT
	| '\\' OCTALDIGIT OCTALDIGIT
	| '\\' OCTALDIGIT OCTALDIGIT OCTALDIGIT;

fragment Hexadecimalescapesequence: '\\x' HEXADECIMALDIGIT+;

fragment Fractionalconstant:
	Digitsequence? '.' Digitsequence
	| Digitsequence '.';

fragment Exponentpart:
	'e' SIGN? Digitsequence
	| 'E' SIGN? Digitsequence;

fragment SIGN: [+-];

fragment Digitsequence: DIGIT ('\''? DIGIT)*;

fragment Floatingsuffix: [flFL];

fragment Encodingprefix: 'u8' | 'u' | 'U' | 'L';

fragment Schar:
	~ ["\\\r\n]
	| Escapesequence
	| Universalcharactername;

fragment Rawstring: 'R"' (( '\\' ["()] )|~[\r\n (])*? '(' ~[)]*? ')'  (( '\\' ["()]) | ~[\r\n "])*? '"';
fragment Rawstring2
: '"'              // Match Opening Double Quote
 ( /* Handle Empty D_CHAR_SEQ without Predicates
      This should also work
      '(' .*? ')'
    */
   '(' ( ~')' | ')'+ ~'"' )* (')'+)

 | D_CHAR_SEQ
       /*  // Limit D_CHAR_SEQ to 16 characters
	  { ( ( getText().length() - ( getText().indexOf("\"") + 1 ) ) <= 16 ) }?
       */
   '('
   /* From Spec :
      Any member of the source character set, except
      a right parenthesis ) followed by the initial D_CHAR_SEQUENCE
      ( which may be empty ) followed by a double quote ".

    - The following loop consumes characters until it matches the
      terminating sequence of characters for the RAW STRING
    - The options are mutually exclusive, so Only one will
      ever execute in each loop pass
    - Each Option will execute at least once.  The first option needs to
      match the ')' character even if the D_CHAR_SEQ is empty. The second
      option needs to match the closing \" to fall out of the loop. Each
      option will only consume at most 1 character
    */
   (   //  Consume everthing but the Double Quote
     ~'"'
   |   //  If text Does Not End with closing Delimiter, consume the Double Quote
     '"'
     {
	  !getText().endsWith(
	       ")"
	     + getText().substring( getText().indexOf( "\"" ) + 1
				  , getText().indexOf( "(" )
				  )
	     + '\"'
	   )
     }?
   )*
 )
 '"'              // Match Closing Double Quote

 /*
 // Strip Away R"D_CHAR_SEQ(...)D_CHAR_SEQ"
 //  Send D_CHAR_SEQ <TAB> ... to Parser
 {
   setText( getText().substring( getText().indexOf("\"") + 1
			       , getText().indexOf("(")
			       )
	  + "\t"
	  + getText().substring( getText().indexOf("(") + 1
			       , getText().lastIndexOf(")")
			       )
	  );
 }
  */
;

fragment D_CHAR_SEQ     // Should be limited to 16 characters
  : D_CHAR+
;
fragment D_CHAR
    /*  Any member of the basic source character set except
	space, the left parenthesis (, the right parenthesis ),
	the backslash \, and the control characters representing
	 horizontal tab, vertical tab, form feed, and newline.
    */
  : '\u0021'..'\u0023'
  | '\u0025'..'\u0027'
  | '\u002a'..'\u003f'
  | '\u0041'..'\u005b'
  | '\u005d'..'\u005f'
  | '\u0061'..'\u007e'
;

UserDefinedIntegerLiteral:
	DecimalLiteral Udsuffix
	| OctalLiteral Udsuffix
	| HexadecimalLiteral Udsuffix
	| BinaryLiteral Udsuffix;

UserDefinedFloatingLiteral:
	Fractionalconstant Exponentpart? Udsuffix
	| Digitsequence Exponentpart Udsuffix;

UserDefinedStringLiteral: StringLiteral Udsuffix;

UserDefinedCharacterLiteral: CharacterLiteral Udsuffix;

fragment Udsuffix: Identifier;

Whitespace: [ \t]+ -> skip;

Newline: ('\r' '\n'? | '\n') -> skip;

BlockComment: '/*' .*? '*/' -> skip;

LineComment: '//' ~ [\r\n]* -> skip;

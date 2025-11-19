/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2015 Camilo Sanchez (Camiloasc1) 2020 Martin Mirchev (Marti2203)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
 * associated documentation files (the "Software"), to deal in the Software without restriction,
 * including without limitation the rights to use, copy, modify, merge, publish, distribute,
 * sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies or
 * substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
 * NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
 * DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 * ****************************************************************************
 */
parser grammar CPP14Parser;
options {
	tokenVocab = CPP14Lexer;
}
/*Basic concepts*/

translationUnit: declarationseq? EOF;
/*Expressions*/

primaryExpression:
	literal+
	| LeftParen expression RightParen
	| LeftParen initializerClause RightParen
	| idExpression
	| lambdaExpression
        | LeftParen compoundStatement RightParen;

idExpression: unqualifiedId | qualifiedId;

unqualifiedId:
	Identifier
	| LeftParen And RightParen LeftBracket Identifier RightBracket
	| operatorFunctionId
	| conversionFunctionId
	| literalOperatorId
	| Tilde (className | decltypeSpecifier)
	| templateId
        | Final
        | New
        | Typename_
        | Override
        | Virtual
        | AndAnd
        | OrOr;

qualifiedId: nestedNameSpecifier Template? unqualifiedId;

nestedNameSpecifier:
	(theTypeName | namespaceName | decltypeSpecifier)? Doublecolon
	| nestedNameSpecifier (
		Identifier
		| Template? simpleTemplateId
	) Doublecolon;
lambdaExpression:
	lambdaIntroducer lambdaDeclarator? compoundStatement;

lambdaIntroducer: LeftBracket lambdaCapture? RightBracket;

lambdaCapture:
	captureList
	| captureDefault (Comma captureList)?;

captureDefault: And | Assign;

captureList: capture (Comma capture)* Ellipsis?;

capture: simpleCapture | initcapture;

simpleCapture: And? Identifier;

initcapture: And? Identifier initializer;

lambdaDeclarator:
	LeftParen parameterDeclarationClause? RightParen Mutable? exceptionSpecification?
		attributeSpecifierSeq? trailingReturnType?;

postfixExpression:
	primaryExpression                                                               # expr1
	| postfixExpression LeftBracket (expression | bracedInitList) RightBracket      # expr2
	| postfixExpression LeftParen expressionList? RightParen                        # funcCall
	| (simpleTypeSpecifier | typeNameSpecifier) (
		LeftParen expressionList? RightParen
		| bracedInitList
	)                                                                               # expr3
	| postfixExpression (Dot | Arrow) (
		Template? idExpression
		| pseudoDestructorName
	)                                                                               # expr4
	| postfixExpression (PlusPlus | MinusMinus)                                     # expr5
	| (
		Dynamic_cast
		| Static_cast
		| Reinterpret_cast
		| Const_cast
	) Less theTypeId Greater LeftParen expression RightParen                        # expr6
	| typeIdOfTheTypeId LeftParen (expression | theTypeId) RightParen               # expr7
        ;
/*
 add a middle layer to eliminate duplicated function declarations
 */

typeIdOfTheTypeId: Typeid_;

expressionList: initializerList;

pseudoDestructorName:
	nestedNameSpecifier? (theTypeName Doublecolon)? Tilde theTypeName
	| nestedNameSpecifier Template simpleTemplateId Doublecolon Tilde theTypeName
	| Tilde decltypeSpecifier;

unaryExpression:
	postfixExpression
	| (PlusPlus | MinusMinus | unaryOperator | Sizeof | Alignof) unaryExpression
	| (Sizeof | Alignof) (
		LeftParen theTypeId RightParen
		| Ellipsis LeftParen Identifier RightParen
	)
	| noExceptExpression
	| newExpression
	| deleteExpression
        | HackBuildin1 LeftParen (typeSpecifier Comma?)+ RightParen
        | HackBuildin2 LeftParen typeSpecifier Comma initializerClause RightParen
        | HackBuildin3 LeftParen idExpression Comma declSpecifierSeq Star? RightParen;

unaryOperator: Or | Star | And | Plus | Tilde | Minus | Not;

newExpression:
	Doublecolon? New newPlacement? (
		newTypeId
		| (LeftParen theTypeId RightParen)
	) newInitializer?;

newPlacement: LeftParen expressionList RightParen;

newTypeId: typeSpecifierSeq newDeclarator?;

newDeclarator:
	pointerOperator newDeclarator?
	| noPointerNewDeclarator;

noPointerNewDeclarator:
	LeftBracket expression RightBracket attributeSpecifierSeq?
	| noPointerNewDeclarator LeftBracket constantExpression RightBracket attributeSpecifierSeq?;

newInitializer:
	LeftParen expressionList? RightParen
	| bracedInitList;

deleteExpression:
	Doublecolon? Delete (LeftBracket RightBracket)? castExpression;

noExceptExpression: Noexcept LeftParen expression RightParen;

castExpression:
	Extension? unaryExpression
	| ((Minus | Tilde | Not)? Star | Minus | Tilde)? LeftParen theTypeId (LeftBracket initializerClause RightBracket)? RightParen castExpression;

pointerMemberExpression:
	castExpression ((DotStar | ArrowStar) castExpression)*;

multiplicativeExpression:
	pointerMemberExpression (
		(Star | Div | Mod) pointerMemberExpression
	)*;

additiveExpression:
	multiplicativeExpression (
		(Plus | Minus) multiplicativeExpression
	)*;

shiftExpression:
	additiveExpression (shiftOperator additiveExpression)*;

shiftOperator: Greater Greater | Less Less;

relationalExpression:
	shiftExpression (
		(Less | Greater | LessEqual | GreaterEqual) shiftExpression
	)*;

equalityExpression:
	relationalExpression (
		(Equal | NotEqual) relationalExpression
	)*;

andExpression: equalityExpression (And equalityExpression)*;

exclusiveOrExpression: andExpression (Caret andExpression)*;

inclusiveOrExpression:
	exclusiveOrExpression (Or exclusiveOrExpression)*;

logicalAndExpression:
	inclusiveOrExpression (AndAnd inclusiveOrExpression)*;

logicalOrExpression:
	logicalAndExpression (OrOr logicalAndExpression)*;

conditionalExpression:
	logicalOrExpression (
		Question (
                expression
                | LeftParen compoundStatement RightParen )? Colon Tilde? Star? assignmentExpression
	)?;

assignmentExpression:
	conditionalExpression
	| logicalOrExpression assignmentOperator initializerClause
	| LeftBracket conditionalExpression (Ellipsis conditionalExpression)? RightBracket assignmentOperator initializerClause
	| throwExpression
        | Extension? LeftParen compoundStatement RightParen;

assignmentOperator:
	Assign
	| StarAssign
	| DivAssign
	| ModAssign
	| PlusAssign
	| MinusAssign
	| RightShiftAssign
	| LeftShiftAssign
	| AndAssign
	| XorAssign
	| OrAssign;

expression: assignmentExpression (Comma assignmentExpression)*;

constantExpression: conditionalExpression;
/*Statements*/

statement:
	labeledStatement
	| declarationStatement
	| attributeSpecifierSeq? (
		expressionStatement
		| compoundStatement
		| selectionStatement
		| iterationStatement
		| jumpStatement
		| tryBlock
	)
        | Extension? LeftParen compoundStatement RightParen;

labeledStatement:
	attributeSpecifierSeq? (
		Identifier
		| Case constantExpression (Ellipsis constantExpression)?
		| Default
	) Colon statement;

expressionStatement: expression? Semi;

compoundStatement: LeftBrace statementSeq? RightBrace;

statementSeq: statement+;

selectionStatement:
	If LeftParen condition RightParen statement (Else statement)?
	| If LeftParen statement condition RightParen statement (Else statement)?
	| Switch LeftParen condition RightParen statement;

condition:
	expression
	| attributeSpecifierSeq? declSpecifierSeq declarator (
		Assign initializerClause
		| bracedInitList
	);

iterationStatement:
	While LeftParen condition RightParen statement
	| Do statement While LeftParen expression RightParen Semi
	| For LeftParen (
		forInitStatement condition? Semi expression?
		| forRangeDeclaration Colon forRangeInitializer
	) RightParen statement;

forInitStatement: expressionStatement | simpleDeclaration;

forRangeDeclaration:
	attributeSpecifierSeq? declSpecifierSeq declarator;

forRangeInitializer: expression | bracedInitList;

jumpStatement:
        Break Semi                                    # JBreak
        | Continue Semi                               # JContinue
        | Return (expression | (LeftParen declSpecifierSeq RightParen)? bracedInitList)? Semi  # JReturn1
        | Goto Identifier Semi                        # JGoto
        ;

declarationStatement: blockDeclaration;
/*Declarations*/

declarationseq: declaration+;

declaration:
	blockDeclaration
	| functionDefinition
	| templateDeclaration
	| explicitInstantiation
	| explicitSpecialization
	| linkageSpecification
	| namespaceDefinition
	| emptyDeclaration
	| attributeDeclaration;

blockDeclaration:
	simpleDeclaration
	| asmDefinition
	| namespaceAliasDefinition
	| usingDeclaration
	| usingDirective
	| staticAssertDeclaration
	| aliasDeclaration
	| opaqueEnumDeclaration;

aliasDeclaration:
	Using Identifier attributeSpecifierSeq? Assign theTypeId Semi;

simpleDeclaration:
	declSpecifierSeq? initDeclaratorList? (Asm Volatile? LeftParen StringLiteral RightParen)? Semi  # simpleDeclare1
	| attributeSpecifierSeq declSpecifierSeq? initDeclaratorList Semi                               # simpleDeclare2
        ;

staticAssertDeclaration:
	Static_assert LeftParen constantExpression Comma StringLiteral RightParen Semi;

emptyDeclaration: Semi;

attributeDeclaration: attributeSpecifierSeq Semi;

declSpecifier:
	storageClassSpecifier
	| typeSpecifier
	| functionSpecifier
	| Friend
	| Extension? Typedef
	| Constexpr
        ;
	
declSpecifierSeq: (declSpecifier (Inline | Inline2)? attributeSpecifierSeq?)+? attributeSpecifierSeq?;

storageClassSpecifier:
	Register
	| Extension? Static
	| Thread_local
	| Extension? Extern
	| Mutable;

functionSpecifier: (Inline | Inline2) | Virtual | Explicit;

typedefName: Identifier;

typeSpecifier:
	trailingTypeSpecifier
	| classSpecifier
	| enumSpecifier
        | Typeof LeftParen (initializerClause | declSpecifierSeq pointerOperator?) RightParen;

trailingTypeSpecifier:
	simpleTypeSpecifier
	| elaboratedTypeSpecifier
	| typeNameSpecifier
	| cvQualifier;

typeSpecifierSeq: typeSpecifier+ attributeSpecifierSeq?;

trailingTypeSpecifierSeq:
	trailingTypeSpecifier+ attributeSpecifierSeq?;

simpleTypeLengthModifier:
	Short
	| Long;
	
simpleTypeSignednessModifier:
	Unsigned
	| Signed;

simpleTypeSpecifier:
	nestedNameSpecifier? theTypeName
	| nestedNameSpecifier Template simpleTemplateId
	| simpleTypeSignednessModifier
	| simpleTypeSignednessModifier? simpleTypeLengthModifier+
	| simpleTypeSignednessModifier? Char
	| simpleTypeSignednessModifier? Char16
	| simpleTypeSignednessModifier? Char32
	| simpleTypeSignednessModifier? Wchar
	| Bool
	| simpleTypeSignednessModifier? simpleTypeLengthModifier* Int
	| Float
	| simpleTypeLengthModifier? Double
	| Void
	| Auto
	| decltypeSpecifier;

theTypeName:
	className
	| enumName
	| typedefName
	| simpleTemplateId
        | decltypeSpecifier;

decltypeSpecifier:
	(Decltype | Decltype2) LeftParen (expression | Auto) RightParen;
	/*(Decltype | Decltype2) LeftParen (expression (Dot Final LeftParen RightParen)? | Auto) RightParen;*/

elaboratedTypeSpecifier:
	classKey (
		attributeSpecifierSeq? nestedNameSpecifier? Identifier
		| simpleTemplateId
		| nestedNameSpecifier Template? simpleTemplateId
	)
	| Enum classKey? nestedNameSpecifier? Identifier;

enumName: Identifier;

enumSpecifier:
	enumHead LeftBrace (enumeratorList Comma?)? RightBrace;

enumHead:
	enumkey attributeSpecifierSeq? (
		nestedNameSpecifier? Identifier
	)? enumbase?;

opaqueEnumDeclaration:
	enumkey attributeSpecifierSeq? Identifier enumbase? Semi;

enumkey: Enum Struct?;

enumbase: Colon typeSpecifierSeq;

enumeratorList:
	enumeratorDefinition (Comma enumeratorDefinition)*;

enumeratorDefinition: enumerator attributeSpecifierSeq? (Assign constantExpression)?;

enumerator: Identifier;

namespaceName: originalNamespaceName | namespaceAlias;

originalNamespaceName: Identifier;

namespaceDefinition:
	(Inline | Inline2)? Namespace (Identifier | originalNamespaceName)? attributeSpecifierSeq? LeftBrace namespaceBody = declarationseq
		? RightBrace;

namespaceAlias: Identifier;

namespaceAliasDefinition:
	Namespace Identifier Assign qualifiednamespacespecifier Semi;

qualifiednamespacespecifier: nestedNameSpecifier? namespaceName;

usingDeclaration:
	Using ((Typename_? nestedNameSpecifier) | Doublecolon) unqualifiedId Semi;

usingDirective:
	attributeSpecifierSeq? Using Namespace nestedNameSpecifier? namespaceName Semi;

asmDefinition: Asm Volatile? LeftParen (
        StringLiteral
        | StringLiteral (Colon | Doublecolon) StringLiteral LeftParen Identifier (Arrow Identifier)? RightParen
        | StringLiteral Colon (StringLiteral (LeftParen Identifier RightParen | logicalOrExpression | initializerClause) (Comma StringLiteral (LeftParen Identifier RightParen | logicalOrExpression | initializerClause))*)? Colon (StringLiteral (LeftParen Identifier RightParen | logicalOrExpression | initializerClause) (Comma StringLiteral (LeftParen Identifier RightParen | logicalOrExpression | initializerClause))*)? Colon StringLiteral
        | StringLiteral Colon ((LeftBracket Identifier RightBracket)? StringLiteral (LeftParen Identifier RightParen | logicalOrExpression | initializerClause) (Comma (LeftBracket Identifier RightBracket)? StringLiteral (LeftParen Identifier RightParen | logicalOrExpression | initializerClause))*)? Colon ((LeftBracket Identifier RightBracket)? StringLiteral (LeftParen Identifier RightParen | logicalOrExpression | initializerClause) (Comma (LeftBracket Identifier RightBracket)? StringLiteral (LeftParen Identifier RightParen | logicalOrExpression | initializerClause))*)?
        | StringLiteral Colon ((LeftBracket Identifier RightBracket)? StringLiteral (LeftParen Identifier RightParen | logicalOrExpression | initializerClause) (Comma (LeftBracket Identifier RightBracket)? StringLiteral (LeftParen Identifier RightParen | logicalOrExpression | initializerClause))*)?
        ) RightParen Semi;

linkageSpecification:
	Extern StringLiteral (
		LeftBrace declarationseq? RightBrace
		| declaration
	);

attributeSpecifierSeq: attributeSpecifier+;

attributeSpecifier:
	Identifier? LeftBracket LeftBracket attributeList? RightBracket RightBracket
	| Identifier? LeftParen LeftParen attributeList? RightParen RightParen
	| alignmentspecifier;

alignmentspecifier:
	Alignas LeftParen (theTypeId | constantExpression) Ellipsis? RightParen;

attributeList: attribute (Comma attribute)* Ellipsis?;

attribute: (attributeNamespace Doublecolon)? Identifier attributeArgumentClause?;

attributeNamespace: Identifier;

attributeArgumentClause: LeftParen balancedTokenSeq? RightParen;

balancedTokenSeq: balancedtoken+;

balancedtoken:
	LeftParen balancedTokenSeq RightParen
	| LeftBracket balancedTokenSeq RightBracket
	| LeftBrace balancedTokenSeq RightBrace
	| ~(
		LeftParen
		| RightParen
		| LeftBrace
		| RightBrace
		| LeftBracket
		| RightBracket
	)+;
/*Declarators*/

initDeclaratorList: initDeclarator (Comma initDeclarator)*;

initDeclarator: declarator (Asm Volatile? LeftParen StringLiteral RightParen)? initializer?;

declarator:
	pointerDeclarator
	| noPointerDeclarator parametersAndQualifiers trailingReturnType;

pointerDeclarator: (pointerOperator Restrict? Const? attributeSpecifierSeq?)* noPointerDeclarator;

noPointerDeclarator:
	declaratorid attributeSpecifierSeq?
	| noPointerDeclarator (
		parametersAndQualifiers
		| LeftBracket Restrict? constantExpression? RightBracket attributeSpecifierSeq?
	)
	| LeftParen pointerDeclarator RightParen
	| LeftBracket parameterDeclarationClause RightBracket;

parametersAndQualifiers:
	LeftParen (parameterDeclarationClause | Ellipsis)? RightParen cvqualifierseq? virtualSpecifierSeq? refqualifier?
		exceptionSpecification? (Asm Volatile? LeftParen StringLiteral RightParen)? attributeSpecifierSeq?;

trailingReturnType:
	Arrow trailingTypeSpecifierSeq abstractDeclarator?;

pointerOperator:
	(And | AndAnd) attributeSpecifierSeq?
	| nestedNameSpecifier? Star attributeSpecifierSeq? cvqualifierseq?;

cvqualifierseq: cvQualifier+;

cvQualifier: Const | Volatile;

refqualifier: And | AndAnd;

declaratorid: Ellipsis? idExpression;

theTypeId: typeSpecifierSeq abstractDeclarator?;

abstractDeclarator:
	pointerAbstractDeclarator
	| noPointerAbstractDeclarator? parametersAndQualifiers trailingReturnType
	| abstractPackDeclarator;

pointerAbstractDeclarator:
	noPointerAbstractDeclarator
	| pointerOperator+ noPointerAbstractDeclarator?;

noPointerAbstractDeclarator:
	noPointerAbstractDeclarator (
		parametersAndQualifiers
		| noPointerAbstractDeclarator LeftBracket constantExpression? RightBracket
			attributeSpecifierSeq?
	)
	| parametersAndQualifiers
	| LeftBracket constantExpression? RightBracket attributeSpecifierSeq?
	| LeftParen pointerAbstractDeclarator RightParen;

abstractPackDeclarator:
	pointerOperator* noPointerAbstractPackDeclarator;

noPointerAbstractPackDeclarator:
	noPointerAbstractPackDeclarator (
		parametersAndQualifiers
		| LeftBracket constantExpression? RightBracket attributeSpecifierSeq?
	)
	| Ellipsis;

parameterDeclarationClause:
	parameterDeclarationList (Comma? Ellipsis)?;

parameterDeclarationList:
	parameterDeclaration (Comma parameterDeclaration)*;

parameterDeclaration:
	attributeSpecifierSeq? declSpecifierSeq (
		(declarator | abstractDeclarator?) (
			Assign initializerClause
		)?
	);

functionDefinition:
	attributeSpecifierSeq? declSpecifierSeq? declarator virtualSpecifierSeq? attributeSpecifierSeq? functionBody;

functionBody:
	constructorInitializer? compoundStatement   # funcBody1
	| functionTryBlock                          # funcBody2
	| Assign (Default | Delete) Semi            # funcBody3
        ;

initializer:
	braceOrEqualInitializer
	| LeftParen expressionList RightParen;

braceOrEqualInitializer:
	Assign initializerClause
	| bracedInitList;

initializerClause: (simpleTypeSpecifier Star? Colon | And LeftParen simpleTypeSpecifier RightParen | LeftParen declSpecifierSeq (Star Const)? LeftBracket RightBracket RightParen | LeftParen Struct Identifier RightParen)? Extension? (Dot? assignmentExpression | bracedInitList);

initializerList:
	Struct? initializerClause Ellipsis? (
		Comma initializerClause Ellipsis?
	)*;

bracedInitList: (LeftParen Identifier RightParen)? LeftBrace (initializerList Comma?)? RightBrace;
/*Classes*/

className: Identifier | simpleTemplateId;

classSpecifier:
	classHead LeftBrace memberSpecification? RightBrace;

classHead:
	Extension? classKey attributeSpecifierSeq? (
		classHeadName classVirtSpecifier?
	)? baseClause?
	| Extension? Union attributeSpecifierSeq? (
		classHeadName classVirtSpecifier?
	)?;

classHeadName: nestedNameSpecifier? className;

classVirtSpecifier: Final;

classKey: Struct | Union;

memberSpecification:
	(memberdeclaration | accessSpecifier Colon)+;

memberdeclaration:
	attributeSpecifierSeq? Extension? declSpecifierSeq? memberDeclaratorList? Semi
	| functionDefinition
	| usingDeclaration
	| staticAssertDeclaration
	| templateDeclaration
	| aliasDeclaration
	| emptyDeclaration;

memberDeclaratorList:
	memberDeclarator (Comma memberDeclarator)*;

memberDeclarator:
	declarator (
		virtualSpecifierSeq? pureSpecifier?
		| braceOrEqualInitializer?
	)
	| Identifier? attributeSpecifierSeq? Colon constantExpression;

virtualSpecifierSeq: virtualSpecifier+;

virtualSpecifier: Override | Final;
/*
 purespecifier: Assign '0'//Conflicts with the lexer ;
 */

pureSpecifier:
	Assign val = OctalLiteral {if($val.text.compareTo("0")!=0) throw new InputMismatchException(this);
		};
/*Derived classes*/

baseClause: Colon baseSpecifierList;

baseSpecifierList:
	baseSpecifier Ellipsis? (Comma baseSpecifier Ellipsis?)*;

baseSpecifier:
	attributeSpecifierSeq? (
		baseTypeSpecifier
		| Virtual accessSpecifier? baseTypeSpecifier
		| accessSpecifier Virtual? baseTypeSpecifier
	);

classOrDeclType:
	nestedNameSpecifier? className
	| decltypeSpecifier;

baseTypeSpecifier: classOrDeclType;

accessSpecifier: Protected | Public;
/*Special member functions*/

conversionFunctionId: (Operator conversionTypeId | OperatorSpecial1 | OperatorSpecial2 | OperatorSpecial3 | OperatorSpecial4 | OperatorSpecial5 | OperatorSpecial6);

conversionTypeId: typeSpecifierSeq conversionDeclarator?;

conversionDeclarator: pointerOperator conversionDeclarator?;

constructorInitializer: Colon memInitializerList;

memInitializerList:
	memInitializer Ellipsis? (Comma memInitializer Ellipsis?)*;

memInitializer:
	meminitializerid (
		LeftParen expressionList? RightParen
		| bracedInitList
	);

meminitializerid: classOrDeclType | Identifier;
/*Overloading*/

operatorFunctionId: Operator theOperator;

literalOperatorId:
	Operator (
		StringLiteral Identifier
		| UserDefinedStringLiteral
	);
/*Templates*/

templateDeclaration:
	Template Less templateparameterList Greater declaration;

templateparameterList:
	templateParameter (Comma templateParameter)*;

templateParameter: typeParameter | parameterDeclaration;

typeParameter:
	Typename_ ((Ellipsis? Identifier?) | (Identifier? Assign theTypeId));

simpleTemplateId:
	templateName Less templateArgumentList? Greater;

templateId:
	simpleTemplateId
	| (operatorFunctionId | literalOperatorId) Less templateArgumentList? Greater;

templateName: Identifier;

templateArgumentList:
	templateArgument Ellipsis? (Comma templateArgument Ellipsis?)*;

templateArgument: (theTypeId | constantExpression | idExpression) (LeftParen Star RightParen LeftBracket Identifier? RightBracket)?;

typeNameSpecifier:
	Typename_ nestedNameSpecifier (
		Identifier
		| Template? simpleTemplateId
	);

explicitInstantiation: Extern? Template declaration;

explicitSpecialization: Template Less Greater declaration;
/*Exception handling*/

tryBlock: Try compoundStatement handlerSeq;

functionTryBlock:
	Try constructorInitializer? compoundStatement handlerSeq;

handlerSeq: handler+;

handler:
	Catch LeftParen exceptionDeclaration RightParen compoundStatement;

exceptionDeclaration:
	attributeSpecifierSeq? typeSpecifierSeq (
		declarator
		| abstractDeclarator
	)?
	| Ellipsis;

throwExpression: Throw assignmentExpression?;

exceptionSpecification:
	dynamicExceptionSpecification
	| noeExceptSpecification;

dynamicExceptionSpecification:
	Throw LeftParen typeIdList? RightParen;

typeIdList: theTypeId Ellipsis? (Comma theTypeId Ellipsis?)*;

noeExceptSpecification:
	Noexcept LeftParen constantExpression RightParen
	| Noexcept;
/*Preprocessing directives*/

/*Lexer*/

theOperator:
	New (LeftBracket RightBracket)?
	| Delete (LeftBracket RightBracket)?
	| Plus
	| Minus
	| Star
	| Div
	| Mod
	| Caret
	| And
	| Or
	| Tilde
	| Not
	| Assign
	| Greater
	| Less
	| GreaterEqual
	| PlusAssign
	| MinusAssign
	| StarAssign
        | DivAssign
	| ModAssign
	| XorAssign
	| AndAssign
	| OrAssign
	| Less Less
	| Greater Greater
	| RightShiftAssign
	| LeftShiftAssign
	| Equal
	| NotEqual
	| LessEqual
	| AndAnd
	| OrOr
	| PlusPlus
	| MinusMinus
	| Comma
	| ArrowStar
	| Arrow
	| LeftParen RightParen
	| LeftBracket RightBracket;

literal:
	IntegerLiteral
	| CharacterLiteral
	| FloatingLiteral
	| StringLiteral
	| BooleanLiteral
	| PointerLiteral
	| UserDefinedLiteral;
	

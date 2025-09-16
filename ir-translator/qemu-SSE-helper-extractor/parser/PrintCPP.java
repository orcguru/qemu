import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.tree.*;

public class PrintCPP {
  public static void main(String[] args) throws Exception {
    ANTLRInputStream input = new ANTLRFileStream(args[0]);
    CPP14Lexer lexer = new CPP14Lexer(input);
    CommonTokenStream tokens = new CommonTokenStream(lexer);
    CPP14Parser parser = new CPP14Parser(tokens);
    ParseTreeWalker walker = new ParseTreeWalker();
    ParseTree entryPoint = parser.translationUnit();
    walker.walk(new CPP14ParserBaseListener(), entryPoint);
    System.out.println(entryPoint.toStringTree(parser));
  }
}

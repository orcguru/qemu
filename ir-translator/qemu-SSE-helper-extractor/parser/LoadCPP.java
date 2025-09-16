import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.tree.*;

public class LoadCPP {
  public static void main(String[] args) throws Exception {
    ANTLRInputStream input = new ANTLRFileStream(args[0]);
    // Get our lexer
    CPP14Lexer lexer = new CPP14Lexer(input);
    // Get a list of matched tokens
    CommonTokenStream tokens = new CommonTokenStream(lexer);
    // Pass the tokens to the parser
    CPP14Parser parser = new CPP14Parser(tokens);
    // Walk it and attach our listener
    ParseTreeWalker walker = new ParseTreeWalker();
    // Specify our entry point
    ParseTree entryPoint = parser.translationUnit();
    walker.walk(new CPP14ParserInfoListener(), entryPoint);
  }
}

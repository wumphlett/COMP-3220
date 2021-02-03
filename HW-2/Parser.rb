# https://www.cs.rochester.edu/~brown/173/readings/05_grammars.txt
#
#  "TINY" Grammar
#
# PGM        -->   STMT+
# STMT       -->   ASSIGN   |   "print"  EXP
# ASSIGN     -->   ID  "="  EXP
# EXP        -->   TERM   ETAIL
# ETAIL      -->   "+" TERM   ETAIL  | "-" TERM   ETAIL | EPSILON
# TERM       -->   FACTOR  TTAIL
# TTAIL      -->   "*" FACTOR TTAIL  | "/" FACTOR TTAIL | EPSILON
# FACTOR     -->   "(" EXP ")" | INT | ID
# ID         -->   ALPHA+
# ALPHA      -->   a  |  b  | … | z  or
#                  A  |  B  | … | Z
# INT        -->   DIGIT+
# DIGIT      -->   0  |  1  | …  |  9
# WHITESPACE -->   Ruby Whitespace

#
#  Parser Class
#
load "Token.rb"
load "Lexer.rb"
class Parser < Scanner
    attr_accessor :errors

    def initialize(filename)
        super(filename)
        @errors = 0
        consume()
    end
       
    def consume()
        @lookahead = nextToken()
        while (@lookahead.type == Token::WS)
            @lookahead = nextToken()
        end
    end
      
    def match(*dtypes)
        if (! dtypes.include? @lookahead.type)
            if (dtypes.length() > 1) # prof output had some weird caps patterns, here's the fix
                dtypes.map!(&:upcase)
            end
            puts "Expected #{dtypes.join(" or ")} found #{@lookahead.text}"
            @errors += 1
        end
        consume()
    end
       
    def program()
        while( @lookahead.type != Token::EOF)
            statement()
        end
        puts "There were #{@errors} parse errors found."
    end

    def statement()
        enter_rule("STMT")

        if (@lookahead.type == Token::PRINT)
            found_token("PRINT")
            match(Token::PRINT)
            exp()
        else
            assign()
        end
        
        exit_rule("STMT")
    end

    def assign()
        enter_rule("ASSGN")

        if (@lookahead.type == Token::ID)
            found_token("ID")
        end
        match(Token::ID)
        if (@lookahead.type == Token::ASSGN)
            found_token("ASSGN")
        end
        match(Token::ASSGN)
        exp()

        exit_rule("ASSGN")
    end

    def exp()
        enter_rule("EXP")

        term()
        etail()

        exit_rule("EXP")
    end

    def term()
        enter_rule("TERM")

        factor()
        ttail()

        exit_rule("TERM")
    end

    def factor()
        enter_rule("FACTOR")

        if (@lookahead.type == Token::LPAREN)
            found_token("LPAREN")
            match(Token::LPAREN)
            exp()
            if (@lookahead.type == Token::RPAREN)
                found_token("RPAREN")
            end
            match(Token::RPAREN)
        elsif (@lookahead.type == Token::INT)
            found_token("INT")
            match(Token::INT)
        elsif (@lookahead.type == Token::ID)
            found_token("ID")
            match(Token::ID)
        else
            match(Token::LPAREN, Token::INT, Token::ID)
        end

        exit_rule("FACTOR")
    end

    def ttail()
        enter_rule("TTAIL")

        if (@lookahead.type == Token::MULTOP)
            found_token("MULTOP")
            match(Token::MULTOP)
            factor()
            ttail()
        elsif (@lookahead.type == Token::DIVOP)
            found_token("DIVOP")
            match(Token::DIVOP)
            factor()
            ttail()
        else
            choose_epsilon("MULTOP", "DIVOP")
        end

        exit_rule("TTAIL")
    end

    def etail()
        enter_rule("ETAIL")

        if (@lookahead.type == Token::ADDOP)
            found_token("ADDOP")
            match(Token::ADDOP)
            term()
            etail()
        elsif (@lookahead.type == Token::SUBOP)
            found_token("SUBOP")
            match(Token::SUBOP)
            term()
            etail()
        else
            choose_epsilon("ADDOP", "SUBOP")
        end

        exit_rule("ETAIL")
    end

    def enter_rule(rule)
        puts "Entering #{rule} Rule"
    end

    def exit_rule(rule)
        puts "Exiting #{rule} Rule"
    end

    def found_token(token)
        puts "Found #{token} Token: #{@lookahead.text}"
    end

    def choose_epsilon(*tokens)
        puts "Did not find #{tokens.join(" or ")} Token, choosing EPSILON production"
    end

end

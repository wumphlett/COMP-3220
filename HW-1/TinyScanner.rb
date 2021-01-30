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
#                  
# ID         -->   ALPHA+
# ALPHA      -->   a  |  b  | … | z  or 
#                  A  |  B  | … | Z
# INT        -->   DIGIT+
# DIGIT      -->   0  |  1  | …  |  9
# WHITESPACE -->   Ruby Whitespace

#
#  Class Scanner - Reads a TINY program and emits tokens
#
class Scanner 
# Constructor - Is passed a file to scan and outputs a token
#               each time nextToken() is invoked.
#   @c        - A one character lookahead 
	def initialize(filename)
		# Need to modify this code so that the program
		# doesn't abend if it can't open the file but rather
        # displays an informative message
        if (File.file?(filename))
            @f = File.open(filename,'r:utf-8')
        else
            raise StandardError, "Specified tiny file does not exist"
        end
		
		# Go ahead and read in the first character in the source
		# code file (if there is one) so that you can begin
		# lexing the source code file 
		if (! @f.eof?)
			@c = @f.getc()
		else
			@c = "eof"
			@f.close()
		end
	end
	
	# Method nextCh() returns the next character in the file
	def nextCh()
        if (! @f.eof?)
			@c = @f.getc()
        else
			@c = "eof"
		end
		
		return @c
	end

	# Method nextToken() reads characters in the file and returns
	# the next token
	# You should also print what you find. Follow the format from the
	# example given in the instructions.
	def nextToken() 
        if (@c == "eof")
			token = Token.new(Token::EOF, "eof")
				
		elsif (whitespace?(@c))
			str = ""
		
			while whitespace?(@c)
				str += @c
				nextCh()
			end
		
			token = Token.new(Token::WS, str)

        elsif (letter?(@c))
            str = ""

            while letter?(@c)
                str += @c
                nextCh()
            end

            # Here is where other keywords would be checked
            if (str == "print")
                token = Token.new(Token::PRINT, str)
            else
                token = Token.new(Token::ID, str)
            end
        
        elsif (numeric?(@c))
            str = ""

            while numeric?(@c)
                str += @c
                nextCh()
            end

            token = Token.new(Token::INT, str)
        
        else

            case @c
            when "("
                token = Token.new(Token::LPAREN, @c)
            when ")"
                token = Token.new(Token::RPAREN, @c)
            when "+"
                token = Token.new(Token::ADDOP, @c)
            when "-"
                token = Token.new(Token::SUBOP, @c)
            when "*"
                token = Token.new(Token::MULTOP, @c)
            when "/"
                token = Token.new(Token::DIVOP, @c)
            when "="
                token = Token.new(Token::EQUAL, @c)
            else
                token = Token.new("unknown", "unknown")
            end

            nextCh()
        end

        puts "Next token is: #{token.type} Next lexeme is: #{token.text}"
        return token
    end
	
end
#
# Helper methods for Scanner
#
def letter?(lookAhead)
	lookAhead =~ /^([a-z]|[A-Z])$/
end

def numeric?(lookAhead)
	lookAhead =~ /^(\d)+$/
end

def whitespace?(lookAhead)
	lookAhead =~ /^(\s)+$/
end

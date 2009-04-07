module Symbolic_contagen
    def method_missing(*args)
        A_symbolic_expression.new(self,*args)
        end
    def coerce(other)
        [A_symbolic_expression.for(other),self]
        end
    end
class A_symbolic_expression
    include Symbolic_contagen
    def initialize(*components)
        @components = components #.collect { |x| A_symbolic_expression.for x }
        end
    def self.for(x)
        case x
          when A_symbolic_expression: x
          when Symbol:                x
          when Array:                 new(x) #Array-proxy and recurse?  Ditto Hash?
          else                        new(x)
          end
        end
    def to_s
        args = @components
        if args[0]
            case args.length
              when 1:               "#{args[0]}"
              when 2:               "#{args[0]}.#{args[1]}"
              else case args[1]
                when :+,:-,:*,:/ :  "(#{args[0]}#{args[1]}#{args[2]})"
                else                "#{args[0]}.#{args[1]}(#{args[2..-1].collect { |a| a.to_s }.join(",")})"
                end
              end
          else
            "#{args[1]}(#{args[2..-1].collect { |a| a.to_s }.join(",")})"
          end
        end
    def inspect
        to_s
        end
    end
class Symbol
    include Symbolic_contagen
    end
def method_missing(meth,*args)
    if meth.to_s =~ /^[A-Z]/ and args.length > 0
        A_symbolic_expression.new(nil,meth,*args)
      else
        super
      end
    end
class Object
    def _
        A_symbolic_expression.new(self)
        end
    def apply
        self
        end
    end


class A_symbolic_expression
    def substitute(vals)
        A_symbolic_expression.new(
           *@components.collect { |x|
               case 
                 when x == nil                  : nil
                 when vals.has_key?(x)          : vals[x]
                 when x.respond_to?(:substitute): x.substitute(vals)
                 else                            x
                 end
               }
           )
        end
    def apply
        print "applying #{to_s}\n"
        (@components[0].apply).send(*@components[1..-1].collect { |x| x.apply })
        end
    end

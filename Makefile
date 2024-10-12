NAME := ft_turing

##### SRC & OBJ PATH #####
SRCPATH := src
INTERFACESPATH := src
OBJPATH := _build
INTERFACE_OBJPATH := _build

##### LIB #####
LIBS =

##### INCLUDE #####
PATH_INCLUDE := $(INTERFACE_OBJPATH)
# HEADERS = $(PATH_INCLUDE)/*.mli
# INC = $(addprefix -I , $(PATH_INCLUDE))


##### COMPILER #####
CC := ocamlc
##### COMPILATION FLAG #####
CCFLAGS =

##### SRCS #####
# INTERFACESPATH := $(addprefix $(SRCPATH)/, parsing.mli)
SRCS := $(addprefix $(SRCPATH)/,parsing.mli parsing.ml main.ml)

# INTERFACE_OBJ := $(INTERFACESPATH:$(SRCPATH)/%.mli=$(INTERFACE_OBJPATH)/%.cmi)
OBJ := $(SRCS:$(SRCPATH)/%.mli=$(OBJPATH)/%.cmi)
OBJS = $(OBJ) $(SRCS:$(SRCPATH)/%.ml=$(OBJPATH)/%.cmo)

### RULES ###

all : mk_objdir $(NAME)
	echo "objs" $(OBJS)
	echo "obj" $(OBJ)

mk_objdir:
	@if [ ! -d $(OBJPATH) ]; then mkdir $(OBJPATH); fi

$(NAME) : $(OBJS)
	@echo "\n$(END)$(BLUE)# Making $(NAME) #$(END)$(GREY)"
	ocamlfind $(CC) -o $@ -linkpkg -package yojson $(OBJ)
	@echo "\n$(END)$(GREEN)# $(NAME) is built #$(END)"

$(OBJPATH)/%.cmi : $(SRCPATH)/%.mli #$(HEADERS)
	ocamlfind $(CC) $(CCFLAGS) -c -package yojson $< -o $@
$(OBJPATH)/%.cmo : $(SRCPATH)/%.ml #$(HEADERS)
	ocamlfind $(CC) $(CCFLAGS) -c -package yojson -I $(PATH_INCLUDE) $< -o $@

### CLEAN ###
.PHONY : sanitize clean fclean re

clean :
	@echo "$(END)$(RED)# removing $(NAME) objects #$(END)$(GREY)"
	rm -rf $(OBJ)
	rm -rf $(INTERFACE_OBJ)

fclean : clean
	@echo "$(END)$(RED)\n# removing $(NAME) #$(END)$(GREY)"
	rm -f $(NAME)

re : fclean all


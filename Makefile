NAME := ft_turing

##### SRC & OBJ PATH #####
SRCPATH := src
INTERFACESPATH := src
OBJPATH := _build
INTERFACE_OBJPATH := _build

##### LIB / DEPENDENCIES #####
PACKAGES = -package yojson

##### INCLUDE #####
PATH_INCLUDE := $(INTERFACE_OBJPATH)
INC = $(addprefix -I , $(PATH_INCLUDE))

##### COMPILER #####
CC := ocamlc
##### COMPILATION FLAG #####
CCFLAGS =

##### SRCS #####
SRCS := $(addprefix $(SRCPATH)/,parsing.mli parsing.ml main.ml)

ML_SRCS := $(filter %.ml, $(SRCS))
MLI_SRCS := $(filter %.mli, $(SRCS))

ML_OBJ := $(ML_SRCS:$(SRCPATH)/%.ml=$(OBJPATH)/%.cmo)
MLI_OBJ := $(MLI_SRCS:$(SRCPATH)/%.mli=$(OBJPATH)/%.cmi)

### RULES ###

all : mk_objdir $(NAME)

mk_objdir:
	@if [ ! -d $(OBJPATH) ]; then mkdir $(OBJPATH); fi

$(NAME) : $(MLI_OBJ) $(ML_OBJ)
	@echo "\n$(END)$(BLUE)# Making $(NAME) #$(END)$(GREY)"
	ocamlfind $(CC) -o $@ -linkpkg $(PACKAGES) $(ML_OBJ)
	@echo "\n$(END)$(GREEN)# $(NAME) is built #$(END)"

$(OBJPATH)/%.cmi : $(SRCPATH)/%.mli
	ocamlfind $(CC) $(CCFLAGS) -c $(PACKAGES) $< -o $@
$(OBJPATH)/%.cmo : $(SRCPATH)/%.ml
	ocamlfind $(CC) $(CCFLAGS) -c $(PACKAGES) $(INC) $< -o $@

### CLEAN ###
.PHONY : sanitize clean fclean re

clean :
	@echo "$(END)$(RED)# removing $(NAME) objects #$(END)$(GREY)"
	rm -rf $(ML_OBJ) $(ML_SRCS:$(SRCPATH)/%.ml=$(OBJPATH)/%.cmi)

fclean : clean
	@echo "$(END)$(RED)\n# removing $(NAME) #$(END)$(GREY)"
	rm -f $(NAME)

re : fclean all


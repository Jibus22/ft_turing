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
MLI_OBJ := $(MLI_SRCS:$(SRCPATH)/%.mli=$(INTERFACE_OBJPATH)/%.cmi)

### RULES ###

all : mk_objdir $(NAME)

mk_objdir:
	@if [ ! -d $(OBJPATH) ]; then mkdir $(OBJPATH); fi

$(NAME) : display_interface $(MLI_OBJ) display_sources $(ML_OBJ)
	$(call print_title,$@,$(RED))
	ocamlfind $(CC) -o $@ -linkpkg $(PACKAGES) $(ML_OBJ)

$(OBJPATH)/%.cmi : $(SRCPATH)/%.mli
	@echo "$(GREEN) ๏$(NC)$< → $@"
	@ocamlfind $(CC) $(CCFLAGS) -c $(PACKAGES) $< -o $@

$(OBJPATH)/%.cmo : $(SRCPATH)/%.ml
	@echo "$(GREEN) ๏$(NC)$< → $@"
	@ocamlfind $(CC) $(CCFLAGS) -c $(PACKAGES) $(INC) $< -o $@

### CLEAN ###
.PHONY : sanitize clean fclean re display_sources display_interface

clean :
	@echo "$(RED) ✗$(NC)$(ML_OBJ) $(ML_SRCS:$(SRCPATH)/%.ml=$(OBJPATH)/%.cmi)"
	@rm -rf $(ML_OBJ) $(ML_SRCS:$(SRCPATH)/%.ml=$(OBJPATH)/%.cmi)

fclean : clean
	@echo "$(RED) ✗$(NC)$(NAME)"
	@rm -f $(NAME)

re : fclean all

### MISC ###

display_interface:
	$(call print_title,interfaces,$(BLUE))
display_sources:
	$(call print_title,sources,$(GREEN))

LINE_LENGTH := 50

print_title = \
							@title_len=$$(echo -n "$(1)" | wc -c); \
							padding_len=$$((($(LINE_LENGTH) - title_len - 2) / 2)); \
							printf "%*s $(2)%s$(NC) %*s\n" $$padding_len "" "$(1)" $$padding_len "" | tr ' ' '≡'

GREEN := \033[0;32m
RED := \033[0;31m
YELLOW := \033[0;33m
BLUE := \033[0;34m
NC := \033[0m  # No Color (reset)

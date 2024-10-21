NAME := ft_turing

TESTNAME := test_exe
##### SRC & OBJ PATH #####
SRCPATH := src
INTERFACESPATH := src
OBJPATH := _build
INTERFACE_OBJPATH := _build
TESTPATH := test

##### LIB / DEPENDENCIES #####
PACKAGES = -package yojson

##### INCLUDE #####
PATH_INCLUDE := $(INTERFACE_OBJPATH)
INC = $(addprefix -I , $(PATH_INCLUDE))

##### COMPILER #####
CC := ocamlc
CCOPT := ocamlopt
##### COMPILATION FLAG #####
CCFLAGS =

##### SRCS #####
SRCS := $(addprefix $(SRCPATH)/,parsing.mli parsing.ml print.ml evaluate.ml main.ml)

ML_SRCS := $(filter %.ml, $(SRCS))
MLI_SRCS := $(filter %.mli, $(SRCS))

ML_OBJ := $(ML_SRCS:$(SRCPATH)/%.ml=$(OBJPATH)/%.cmo)
ML_OBJ_OPT := $(ML_SRCS:$(SRCPATH)/%.ml=$(OBJPATH)/%.cmx)
MLI_OBJ := $(MLI_SRCS:$(SRCPATH)/%.mli=$(INTERFACE_OBJPATH)/%.cmi)

TESTSRCS := $(addprefix $(TESTPATH)/, t_parsing.ml)
TEST_OBJ := $(TESTSRCS:$(TESTPATH)/%.ml=$(TESTPATH)/%.cmo)
TEST_OBJI := $(TESTSRCS:$(TESTPATH)/%.ml=$(TESTPATH)/%.cmi)

### RULES ###

all : mk_objdir $(NAME)

$(NAME) : display_interface $(MLI_OBJ) display_sources $(ML_OBJ)
	$(call print_title,$@,$(YELLOW))
	ocamlfind $(CC) -o $@ -linkpkg $(PACKAGES) $(ML_OBJ)

opt : mk_objdir display_interface $(MLI_OBJ) display_sources $(ML_OBJ_OPT)
	$(call print_title,$(NAME),$(YELLOW))
	ocamlfind $(CCOPT) -o $(NAME) -linkpkg $(PACKAGES) $(ML_OBJ_OPT)

test: mk_objdir display_interface $(MLI_OBJ) display_sources $(ML_OBJ) $(TEST_OBJ)
	$(call print_title,$(TESTNAME),$(YELLOW))
	ocamlfind $(CC) -o $(TESTNAME) -linkpkg $(PACKAGES),alcotest $(filter-out $(OBJPATH)/main.cmo, $(ML_OBJ)) $(TEST_OBJ)

mk_objdir:
	@if [ ! -d $(OBJPATH) ]; then mkdir $(OBJPATH); fi

$(OBJPATH)/%.cmi : $(SRCPATH)/%.mli
	@echo "$(BLUE) ๏$(NC)$< → $@"
	@ocamlfind $(CC) $(CCFLAGS) -c $(PACKAGES) $< -o $@

$(OBJPATH)/%.cmo : $(SRCPATH)/%.ml
	@echo "$(GREEN) ๏$(NC)$< → $@"
	@ocamlfind $(CC) $(CCFLAGS) -c $(PACKAGES) $(INC) $< -o $@

$(OBJPATH)/%.cmx : $(SRCPATH)/%.ml
	@echo "$(GREEN) ๏$(NC)$< → $@"
	@ocamlfind $(CCOPT) $(CCFLAGS) -c $(PACKAGES) $(INC) $< -o $@

$(TESTPATH)/%.cmo : $(TESTPATH)/%.ml
	@echo "$(GREEN) ๏$(NC)$< → $@"
	@ocamlfind $(CC) $(CCFLAGS) -c $(PACKAGES),alcotest $(INC) $< -o $@

### CLEAN ###
.PHONY : clean fclean re display_sources display_interface opt test

ALL_OBJECTS=\
						$(ML_OBJ)\
						$(ML_SRCS:$(SRCPATH)/%.ml=$(OBJPATH)/%.cmi)\
						$(ML_SRCS:$(SRCPATH)/%.ml=$(OBJPATH)/%.cmx)\
						$(ML_SRCS:$(SRCPATH)/%.ml=$(OBJPATH)/%.o)

clean :
	@echo "$(RED) ✗$(NC)$(ALL_OBJECTS)"
	@rm -f $(ALL_OBJECTS)

clean_test :
	@echo "$(RED) ✗$(NC)$(TEST_OBJ) $(TEST_OBJI) $(TESTNAME)"
	@rm -f $(TEST_OBJ) $(TEST_OBJI) $(TESTNAME)

fclean : clean clean_test
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

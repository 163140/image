PROJECT = image
PROJECT_DESCRIPTION = Набор функций для создания примитивов силами imagemagic
PROJECT_VERSION = 0.0.0

DEPS = line point
dep_line = git http://some.where
dep_point = git http://some.where

include erlang.mk

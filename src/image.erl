-module(image).
-export([trapezium/3, blank/2, merge/2]).
-include_lib("eunit/include/eunit.hrl").
-author("ea1a87").

-type point()	::	{point	, float()		, float()		}	. %% Точка в двухмерном пространстве
-type line()	::	{line		, point()		, point()		}	.	%% Прямая на плоскости проходящая заданная двумя точками
-type canvas()::	{canvas	, integer()	, integer()	}	. %% Размер холста
-type color()	::	{color	,	string()							}	.	%% Цвет
-type	filename():: string().


%% @doc Возврыщает сумму двух координат точки на плоскости
-spec str2( point() ) -> integer().
str2(A) -> {point, X, Y} = A, X+Y.

%% @doc Имя промежуточного файла
-spec randName( point(), point(), point(), point() ) -> filename().
randName(A, B, C, D) -> lists:concat(str2(A), str2(B), str2(C), str2(D), ".png").

%% @doc Отрисовывает трапецию  с использованием Imagemagick.
-spec trapezium( Points::list( point() ), canvas(), list( color() ) ) -> [].
trapezium(Points, Canvas, Colors) ->
	{canvas, Xres, Yres}	=	Canvas,
	[	{color,	ColorBorder	},
		{color,	ColorFill		}]	=	Colors,
  [A, B, C1, C2]				= Points, % А,В - основание; С1, С2 - верхнее основание
 
	{point, _, YD} = line:intersect({line, A, C1}, {line, B, C2}), % точка D определяется путем достройки трапеции до треугольника
  {point, _, YC} = C1	,
  {point, _, YB} = B	,
	
  Opacity		= round3((YC-YB)/(YD-YB)),
  TempFile	= randName(A, B, C1, C2),
	% convert -size 100x60 xc:none -fill none -stroke black -draw "polygon 20,10 20,20 80,50"       draw.png
	DrawCMD		= lists:concat(
		"convert -size ", [Xres], "x", [Yres], " -fill ", ColorFill, " -stroke ", ColorBorder, " -draw \"polygon ",
		point:str(A), " ", point:str(B), " ", point:str(C2), " ", point:str(C2), "\" -alpha set -background none -channel A ",
		"-evaluate multiply ", [Opacity], " +channel ", TempFile),
  os:cmd(DrawCMD).

-spec blank( canvas(), filename() ) -> [].
blank(Canvas, File) ->
	{canvas, Xres, Yres} = Canvas,
	os:cmd( lists:concat(["convert -size ", Xres, "x", Yres, " xc:none ", File])).

% Image = "/home/.../image.png"
merge(MainImage, TempImage) ->
  CMD = lists:concat(["convert -composite ", MainImage, " ",  TempImage, " ", MainImage]),
  os:cmd(CMD).

-spec round3( number() ) -> float().
round3(Num) -> round(Num*1000)/1000.

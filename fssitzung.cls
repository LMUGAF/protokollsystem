\ProvidesClass{fssitzung}[2015/05/09 Fachschaftssitzungs class by GAF]
\LoadClass[a4paper,parskip,fontsize=9pt,DIV=12]{scrartcl}

\RequirePackage{iftex}

\ifPDFTeX
			\RequirePackage[utf8]{inputenc}
			\RequirePackage[ngerman]{babel}
			\RequirePackage[T1]{fontenc}
\else
	% Don't switch the order: github.com/reutenauer/polyglossia/issues/50
	\ifLuaTeX
			\RequirePackage[ngerman]{babel}
			\RequirePackage[pdftex]{graphicx} % graphix always before hyperref
			\RequirePackage[pdftex,hidelinks]{hyperref}
	\else
		\ifXeTeX
			\RequirePackage{polyglossia}
			\setdefaultlanguage[babelshorthands=true]{german}
			\RequirePackage{xunicode} % loads graphicx so load it before hyperref
			\RequirePackage[xetex,hidelinks]{hyperref}
		\fi
	\fi
\fi


\RequirePackage{lmodern}
\RequirePackage{microtype}

\RequirePackage{datatool}
\RequirePackage{xparse}
\RequirePackage{etoolbox}
\RequirePackage{ifthen}
\RequirePackage{collect}
\RequirePackage{wasysym}
\RequirePackage{marvosym}
\RequirePackage{xcolor}
\RequirePackage{mdframed}
\RequirePackage{dingbat}
\RequirePackage{enumitem}
\RequirePackage{graphicx}
\RequirePackage{fancyhdr}
\RequirePackage{geometry}
\RequirePackage[compact]{titlesec}







%% @TODO make @ version (which fails for now)
\NewDocumentCommand\beginn{m}{%
	\gdef\fssStart{#1}%
}

%% @TODO make @ version (which fails for now)
\NewDocumentCommand\ende{m}{%
	\gdef\fssEnd{#1}%
}


\def\defClearCollection#1{%
	\definecollection{#1}%
	\begin{collect}{#1}{}{}\end{collect}}


%% ## Internal/External ########################################################
%% ==== Detection ==============================================================
\newtoggle{fss@forExternal}

%% Only if the jobname is "internal" (xelatex -jobname internal ...), a version
%% with confidential informations is generated. This pessimistic logic hopefully
%% prevents some fails.
\expandafter\ifstrequal\expandafter{\jobname}{internal}%
{\togglefalse{fss@forExternal}}%
{\toggletrue{fss@forExternal}}


%% ==== User commands ==========================================================
\NewDocumentCommand\intern{m}{%
	\iftoggle{fss@forExternal}{}{#1}%
}

\NewDocumentCommand\extern{m}{%
	\iftoggle{fss@forExternal}{#1}{}%
}

\NewDocumentCommand\internextern{mm}{%
	\iftoggle{fss@forExternal}{#2}{#1}%
}



%% ## Design ###################################################################
%% ==== Page ===================================================================
\geometry{
	includehead,
	includefoot,             %% vvv Margin        vvv Margin
	top=1cm,                 %% Upper page   <--> Upper head
	headsep=.8cm,            %% Lower head   <--> Upper text
	bottom=0cm,              %% Lower text   <--> Lower footer(!)
	footskip=1cm,            %% Lower footer <--> Lower page
	left=2.5cm,
	right=2.5cm,
	%showframe    %TODO REMOVE BEFORE PRODUCTION
}


%% ==== Titles =================================================================
%% Set the font style
\titleformat*{\section}      {\normalfont\huge\sffamily\bfseries}
\titleformat*{\subsection}   {\normalfont\normalsize\sffamily\bfseries}
\titleformat*{\subsubsection}{\normalfont\small\sffamily\bfseries}

%% Set left margin and the space above and below the title. The last two are
%% relative to the default "compact" style set with the titlesec package loading
%% options
\titlespacing{\section}{0cm}{*3}{*0}
\titlespacing{\subsection}{0cm}{*1}{*0}
\titlespacing{\subsubsection}{0pt}{*0}{*0}

%% Put gray title numbers in the margin
\renewcommand{\@seccntformat}[1]{%
	\llap{%
		\textcolor{black!50}%
		{\csname the#1\endcsname}%
		\hspace{1em}%
	}%
}


%% ==== Definition lists =======================================================
%% This is later used as the alignment style of the definition list following
%% the title
\SetLabelAlign{parright}{\parbox[t]{\labelwidth}{\raggedleft#1}}


%% ==== Pro & Contra ===========================================================
\newmdenv[
	topline=false,
	bottomline=false,
	rightline=false,
	skipabove=1em,
	leftmargin=-.9em,
	innermargin=0pt,
	innertopmargin=0pt,
	innerbottommargin=0pt,
	innerleftmargin=0pt,
	linecolor=green!60,
	linewidth=2.5pt,
]{proBox}

\newmdenv[
	topline=false,
	bottomline=false,
	rightline=false,
	skipabove=1em,
	leftmargin=-.9em,
	innermargin=0pt,
	innertopmargin=0pt,
	innerbottommargin=0pt,
	innerleftmargin=0pt,
	linecolor=red!60,
	linewidth=2.5pt,
]{conBox}





%% ## Blocks with big & small veersion #########################################
%% ==== Block macro template ===================================================
%% Create a collection for all environment contents which have to be ignored
%% because of internal content in external versions
\defClearCollection{fss@ignore}

%% m: command macro name (german, all lowercase)
%% m: environment macro name (german, all caps)
%% m: end of the make macro name (english, first letter cap)
%% m: Title of all blocks (german)
%% m: Description if no block is defined in document (german)
%%    Competes "Keine $m."
\NewDocumentCommand\@fss@makeCommands{m m m m m}{
	\defClearCollection{fss@#1CollectionC}
	\defClearCollection{fss@#2CollectionE}
	
	\newtoggle{fss@#1FoundC}
	\newtoggle{fss@#2FoundE}
	
	%% User environment for the block
	%% s: Stared environment: Only for internal versions
	%% m: Title of the block
	\DeclareDocumentEnvironment{#2}{s m}{%
		\ifboolexpr{togl{fss@forExternal} and test{\IfBooleanTF ##1}}{
			%% For the external version of a stared environment, collect the
			%% environment content in the "fss@ignore" collection, which will
			%% never be used.
			\@nameuse{collect}{fss@ignore}{}{}
		}{
			\@nameuse{collect}{fss@#2CollectionE}{}{}
				\toggletrue{fss@#2FoundE}
				\subsection{##2}
		}
	}{% BODY
		\@nameuse{endcollect}
	}
	
	%% User command for the block
	%% s: Stared environment: Only for internal versions
	%% o: Title of the block
	%% m: Content of the block
	\expandafter\NewDocumentCommand\csname #1\endcsname{s o m}{
		\ifboolexpr{togl{fss@forExternal} and test{\IfBooleanTF ##1}}{
			%% Do nothing in external version with the stared command
		}{
			\IfNoValueTF{##2}{%
				%% If no title is given, collect an item for the list.
				\toggletrue{fss@#1FoundC}
				
				\begin{collect}{fss@#1CollectionC}{}{}
					\item ##3
				\end{collect}
			}{%
				%% If a title is given, use the environment of the block to
				%% create the "big" version.
				\begin{#2}{##2}
					##3
				\end{#2}
			}
		}
	}
	
	%% @TODO make @ version (which fails for now)
	\expandafter\NewDocumentCommand\csname make#3\endcsname{}{
		\section{#4}
		%
		%% Include the big version's collection (which can be empyt)
		\includecollection{fss@#2CollectionE}
		%
		\iftoggle{fss@#1FoundC}{%
			%% Include the small version's collection only if there are
			%% collected items. Otherwise there would be an empty list taking up
			%% space.
			%% 
			%% A own subsection for the small version's collection is only 
			%% needed on preciding the big version's collection.
			\iftoggle{fss@#2FoundE}{\subsection{Sonstiges}}{}
			%
			\begin{itemize}
				\includecollection{fss@#1CollectionC}
			\end{itemize}
		}{
			\iftoggle{fss@#2FoundE}{}{Keine #5.}
		}
	}
}


%% ==== Instantiate blocks =====================================================
%{<Name Befehl>}{<Name Umgebung>}{<makeName>}{<Überschrift>}{<Bezeichnung in Text>}
%% Creates \was, \begin{WAS}\end{WAS} and \makeWas
\@fss@makeCommands{was}{WAS}{Was}{W.A.S.}{W.A.S. Punkte}

%% Creates \post, \begin{POST}\end{POST} and \makeMail
\@fss@makeCommands{post}{POST}{Mail}{Post und E-Mails}{relevante Post}

%% Creates \diskussion, \begin{DISKUSSION}\end{DISKUSSION} and \makeDiscussions
\@fss@makeCommands{diskussion}{DISKUSSION}{Discussions}{Diskussion}{Diskussionen}

%% Creates \bericht, \begin{BERICHT}\end{BERICHT} and \makeReports
\@fss@makeCommands{bericht}{BERICHT}{Reports}{Berichte}{Berichte}


%% ==== Shortcuts ==============================================================
\NewDocumentCommand\berichtFakRat{m}{
	\bericht{Fakultätsrat #1}
}


%% ## Motion blocks ############################################################

\defClearCollection{fss@motionCollection}
\newtoggle{fss@motionFound}


\NewDocumentEnvironment{ANTRAG}{m m}{%
	\collect{fss@motionCollection}{%
		\subsection{#2}%
		\toggletrue{fss@motionFound}%
	}{% BODY
		\edef\status{#1}%
		%
		\ifdefstring{\status}{angenommen}{\par $\Rightarrow$ Der Antrag wurde einstimmig angenommen.}{%
		\ifdefstring{\status}{abgelehnt}{\par $\Rightarrow$ Für den Antrag konnte kein Konsens gefunden werden.}{%
			\PackageError{fssitzung}%
			{Das erste Argument von \\ANTRAG und \\antrag muss "angenommen", "abgelehnt" oder leer sein.}%
			{Das erste Argument von \\ANTRAG und \\antrag muss "angenommen", "abgelehnt" oder leer sein.}%
			\stop%
		}}%
	}%
}{% BODY
	\endcollect%
}

%% The small version is displayed exactly the same as the big version
\NewDocumentCommand\antrag{m m G{}}{%
	\begin{ANTRAG}{#1}{#2}#3\end{ANTRAG}%
}

%% @TODO make @ version (which fails for now)
\NewDocumentCommand\makeMotions{}{
	\section{Anträge}
	\includecollection{fss@motionCollection}
	\iftoggle{fss@motionFound}{}{Keine Anträge.}
}

%% ==== Shortcuts ==============================================================
\NewDocumentCommand\transponderAntrag{m}{
	\antrag{angenommen}{#1 bekommt einen Transponder}
}

\NewDocumentCommand\accountAntrag{m}{
	\antrag{angenommen}{#1 bekommt einen Account}
}


%%%%%%%%%%%%% Date %%%%%%%%%%%%%

\DTLnewdb{dateDb}
\DTLaddcolumn{dateDb}{when}

\NewDocumentCommand\termin{m m}{%
	\DTLnewrow{dateDb}%
	\DTLnewdbentry{dateDb}{what}{#2}%
	\DTLnewdbentry{dateDb}{when}{#1}%
}

\NewDocumentCommand\makeDates{}{
	\section{Anstehende Termine}
	
	\DTLifdbempty{oldTodoDb}{
		Keine
	}{
		\begin{itemize}
			\DTLsort{when}{dateDb}%
			\DTLforeach*{dateDb}{\theWhat=what,\theWhen=when}{%
				\item \textbf{\theWhen}\\\theWhat
			}%
		\end{itemize}
	}
}


%%%%%%%%%%%%% Old ToDo %%%%%%%%%%%%%

\DTLnewdb{oldTodoDb}
\DTLaddcolumn{oldTodoDb}{done}
\DTLaddcolumn{oldTodoDb}{what}
\DTLaddcolumn{oldTodoDb}{status}
\DTLaddcolumn{oldTodoDb}{who}
\DTLaddcolumn{oldTodoDb}{until}

\NewDocumentCommand\alttodo{o m o d() o}{
	\DTLnewrow{oldTodoDb}%
	\DTLnewdbentry{oldTodoDb}{what}{#2}%
	\DTLnewdbentry{oldTodoDb}{who}{#4}%
	\IfNoValueTF{#1}{}{\DTLnewdbentry{oldTodoDb}{done}{#1}}%
	\IfNoValueTF{#3}{}{\DTLnewdbentry{oldTodoDb}{status}{#3}}%
	\IfNoValueTF{#5}{}{\DTLnewdbentry{oldTodoDb}{until}{#5}}%
}

\NewDocumentCommand\makeOldTodo{}{
	\section{Alte ToDo}
	
	\DTLifdbempty{oldTodoDb}{
		Keine
	}{
		\begin{itemize}
		\DTLsort{who,until}{oldTodoDb}
		\DTLforeach*{oldTodoDb}{\theDone=done,\theWhat=what,\theStatus=status,\theWho=who,\theUntil=until}{%
			\item[\DTLifnull{\theDone}{$\Box$}{\Checkedbox}] %
			\theWhat\intern{ (\theWho)}%
			\DTLifnull{\theStatus}{}{\\\emph{Status: \theStatus}}%
			\DTLifnull{\theUntil}{}{\\\emph{Bis: \theUntil}}%
			\DTLifnull{\theDone}{%
				\DTLifnull{\theUntil}{%
					\edef\foox{\todox{\theWhat}{\theWho}{\thesection}}%
				}{%
					\edef\foox{\todox{\theWhat}{\theWho}{\thesection}[\theUntil]}%
				}%
			}{%
				\DTLifnull{\theUntil}{%
					\edef\foox{\todox[\theDone]{\theWhat}{\theWho}{\thesection}}%
				}{%
					\edef\foox{\todox[\theDone]{\theWhat}{\theWho}{\thesection}[\theUntil]}%
				}%
			}%
			\foox%
		}%
		\end{itemize}
	}
}

%% @TODO In \alttodo und \todo neue \alttodo in einer collection speichern, die nicht im tex selbst verwendet wrid, sondern wo nacher nur das file rausgeklaut wird, für das nächste protokoll

%% @TODO "[done]" an das ende verschieben, und prüfen ob das konsistent überall geht

%%%%%%%%%%%%% ToDo %%%%%%%%%%%%%

\DTLnewdb{todoDb}
\DTLaddcolumn{todoDb}{who}
\DTLaddcolumn{todoDb}{where}
\DTLaddcolumn{todoDb}{until}
\DTLaddcolumn{todoDb}{done}

\NewDocumentCommand\todo{o m d() o}{
	%\par\emph{\IfNoValueTF{#1}{ToDo: }{ToDo \checkmark: }}#2 (#3)%
	\par\emph{ToDo: }#2\intern{ (#3)} \IfNoValueTF{#1}{}{ \checkmark}%
	\IfNoValueTF{#4}{}{\\\emph{Bis #4}}%
	\edef\foox{\todox[#1]{#2}{#3}{\ifnumgreater{\value{subsection}}{0}{\thesubsection}{\thesection}}[#4]}%
	\foox%
}

\NewDocumentCommand\todox{ommmo}{
	\DTLnewrow{todoDb}%
	\DTLnewdbentry{todoDb}{what}{#2}%
	\DTLnewdbentry{todoDb}{who}{#3}%
	\DTLnewdbentry{todoDb}{where}{#4}%
	%
	%% Add an "until" flag in the ToDo DB & add a date
	\IfNoValueTF{#5}{}{%
		\DTLnewdbentry{todoDb}{until}{#5}%
		\IfNoValueTF{#1}{%
			\edef\barx{\termin{#5}{Deadline für #3: #2 (siehe #4)}}%
			\barx%
		}{}%
	}%
	%
	%% Add an "done" flag in the ToDo DB
	\IfNoValueTF{#1}{}{
		\expandafter\ifstrequal\expandafter{#1}{done}{}{%
			\PackageError{fssitzung}%
			{Das erste Argument von \\todo und \\alttodo muss "done" oder leer sein.}%
			{Das erste Argument von \\todo und \\alttodo muss "done" oder leer sein.}%
			\stop%
		}%
		\DTLnewdbentry{todoDb}{done}{#1}
	}%
}

\NewDocumentCommand\makeTodo{}{
	\section{ToDo}
	
	\DTLifdbempty{todoDb}{
		Keine
	}{
		\DTLsort{who,where,until}{todoDb}
		\DTLforeach*{todoDb}{\theWhat=what,\theWho=who,\theWhere=where,\theUntil=until,\theDone=done}{%
			\DTLifnull{\theDone}{
				\ifdefequal{\lastWho}{\theWho}{}{
					\ifundef{\lastWho}{}{\end{itemize}}
					\subsection{\theWho}
					\edef\lastWho{\theWho}
					\begin{itemize}
				}
				\item[\DTLifnull{\theDone}{$\Box$}{\Checkedbox}] \theWhat\ (siehe \theWhere)%
				\DTLifnull{\theUntil}{}{\\\emph{Bis \theUntil}}%
			}{}
		}%
		\ifundef{\lastWho}{}{\end{itemize}}
	}
}


%%%%%%%%%%%%% Pro/Con %%%%%%%%%%%%%

%%%%%% B %%%%%%

%\newbool{insidePro}
%\newbool{insideCon}
%
%\NewDocumentCommand\pro{m}{
%	\ifbool{insidePro}{}
%	{
%		\begin{itemize}[labelsep = 6pt, leftmargin=16pt]
%		\booltrue{insidePro}
%	}
%	
%	\item[\includegraphics{plus.pdf}] #1
%	
%	\@ifnextchar\pro{}
%	{
%		\end{itemize}
%		\boolfalse{insidePro}
%	}
%}
%
%\NewDocumentCommand\con{m}{
%	\ifbool{insideCon}{}
%	{
%		\begin{itemize}[labelsep = 6.5pt, leftmargin=16pt]
%		\booltrue{insideCon}
%	}
%	
%	\item[\includegraphics{minus.pdf}] #1
%	
%	\@ifnextchar\con{}
%	{
%		\end{itemize}
%		\boolfalse{insideCon}
%	}
%}

%%%%%% L %%%%%%




\newbool{insidePro}
\boolfalse{insidePro}

\makeatletter
\NewDocumentCommand\pro{m}{
	\ifbool{insidePro}
	{}
	{
		\begin{proBox}%
		\smash{%
			\makebox[0pt][r]{%
				\raisebox{-.69cm}%
				{\fcolorbox{green!60}{green!60}{\parbox[c][.5cm][c]{.5cm}{\color{black}\rightthumbsup}}\hspace{0pt}}%
			}%
		}%
		\begin{itemize}%
		\booltrue{insidePro}
	}
	
	\item #1
	
	\@ifnextchar\pro
	{}
	{\end{itemize}\end{proBox}}
}
\makeatother




\newbool{insideCon}
\boolfalse{insideCon}

% http://ux.stackexchange.com/questions/36597/best-way-to-display-plus-minus-or-pros-cons-short-sentences
\makeatletter
\NewDocumentCommand\con{m}{
	\ifbool{insideCon}
	{}
	{%
		\begin{conBox}%
		\smash{%
			\makebox[0pt][r]{%
				\raisebox{-.69cm}%
				{\fcolorbox{red!60}{red!60}{\parbox[c][.5cm][c]{.5cm}{\color{black}\rightthumbsdown}}\hspace{0pt}}%
			}%
		}%
		\begin{itemize}%
		\booltrue{insideCon}%
	}%
	%
	\item #1
	
	\@ifnextchar\con
	{}
	{\end{itemize}\end{conBox}}
}
\makeatother


%%%%%%%%%%%%% Anwesenheit %%%%%%%%%%%%%

\DTLnewdb{anwesendDb}
\DTLnewdb{modDb}
\DTLnewdb{protDb}

\DTLaddcolumn{anwesendDb}{name}
\DTLaddcolumn{anwesendDb}{from}
\DTLaddcolumn{anwesendDb}{to}
\DTLaddcolumn{modDb}{name}
\DTLaddcolumn{modDb}{from}
\DTLaddcolumn{modDb}{to}
\DTLaddcolumn{protDb}{name}
\DTLaddcolumn{protDb}{from}
\DTLaddcolumn{protDb}{to}

\NewDocumentCommand\anwesend{o d() m d()}
{
	\edef\type{#1}
	
	\IfNoValueTF{#1}{
		\def\dbName{anwesendDb}
	}{
		\ifdefstring{\type}{leitung}{\def\dbName{modDb}}{%
		\ifdefstring{\type}{protokoll}{\def\dbName{protDb}}{%
		\PackageError{fssitzung}{Ungueltige Rolle}{Erstes Argument bei \\anwesend muss "leitung", "prokotoll" oder nicht gesetzt sein.}\stop
	}}}
	
	\DTLnewrow{\dbName}
	
	\DTLnewdbentry{\dbName}{name}{#3}
	\IfNoValueTF{#2}{}{\DTLnewdbentry{\dbName}{from}{#2}}
	\IfNoValueTF{#4}{}{\DTLnewdbentry{\dbName}{to}{#4}}
}

\newcommand{\personlist}[1]{%
	\DTLsort{name}{#1}%
	%
	\DTLforeach*{#1}{\theName=name,\theFrom=from,\theTo=to}{%
		\DTLiffirstrow{}{\DTLiflastrow{ und}{,}} %
		\theName %
		\DTLifnull{\theFrom}{%
			\DTLifnull{\theTo}{}{ (bis {\theTo} Uhr)}%
		}{ %
			(ab \theFrom \DTLifnull{\theTo}{}{ bis \theTo} Uhr)%
		}%
	}%
}


%%%%%%%%%%%%% Dokumenterzeugung %%%%%%%%%%%%%
\NewDocumentCommand\sitzung{m}{
	\subtitle{\internextern{\emph{Internes}}{Öffentliches} Protokoll}
	\title{Fachschaftssitzung}
	\date{\vspace{-1cm}#1}
	
	\makeatletter
	\fancyhf{}
	\fancyhead[L]{\internextern{Internes}{Öffentliches} Protokoll der Fachschaftssitzung vom #1}
	\fancyhead[R]{Seite \thepage}
	\makeatother
	
	
	\pagestyle{fancy}
	\begin{document}
		\maketitle
		\thispagestyle{empty}
		
		\begin{description}[
			style=multiline,
			leftmargin=3cm,
			rightmargin=1cm,
			align=parright
		]
			        \item[Anwesend]       \internextern{\personlist{anwesendDb}}{\DTLrowcount{anwesendDb} Personen}
			\intern{\item[Sitzungleitung] \personlist{modDb}}
			\intern{\item[Protokoll]      \personlist{protDb}}
			        \item[Beginn]         \makeatletter\fssStart\makeatother
			        \item[Ende]           \makeatletter\fssEnd\makeatother
		\end{description}
		
		%% The first section starts traditionally with 0 (tzzz, computer
		%% scientists). Therefor we have to set section to -1
		\setcounter{section}{-1}
		\section{Sitzungsleitung und Protokoll}
		Die Vorschläge zu Sitzungsleitung und Protokollanten wurden angenommen.
		
		\makeMail
		\makeOldTodo
		\makeReports
		\makeDiscussions
		\makeMotions
		\makeWas
		\makeDates
		\intern{\makeTodo}
	\end{document}
}
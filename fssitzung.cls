\ProvidesClass{fssitzung}[2014/04/30 Fachschaftssitzungs class by GAF]
\LoadClass[a4paper,parskip,fontsize=9pt,DIV=12]{scrartcl}

\RequirePackage[utf8]{inputenc}
\RequirePackage[ngerman]{babel}
\RequirePackage[T1]{fontenc}
\RequirePackage{microtype}

\RequirePackage{datatool}
\RequirePackage{xparse}
\RequirePackage{etoolbox}
\RequirePackage{ifthen}
\RequirePackage{environ}
\RequirePackage{collect}
\RequirePackage{wasysym}
\RequirePackage{marvosym}
\RequirePackage{xcolor}
\RequirePackage{mdframed}
\RequirePackage{dingbat}
%\RequirePackage[hscale=0.75,vscale=0.85,vmarginratio={2:3},heightrounded]{geometry}

\RequirePackage[
    %inner=20mm, % left margin
    %outer=10mm, % right margin
    top=20mm,
    bottom=25mm,
    %bindingoffset=0mm,
    nohead,
    %showframe    %TODO REMOVE BEFORE PRODUCTION
    ]{geometry}



\RequirePackage[compact]{titlesec}
\titlespacing{\section}{0pt}{*0}{*0}
\titlespacing{\subsection}{0pt}{*0}{*0}
\titlespacing{\subsubsection}{0pt}{*0}{*0}

\newcommand{\renewdb}[1]{%
	\DTLifdbexists{#1}{%
		\DTLcleardb{#1}%
	}{%
		\DTLnewdb{#1}%
	}
}


\newbool{public}

\ifdefstring{\jobname}{private}%
{\boolfalse{public}}
{\booltrue{public}}


% 	\NewDocumentEnvironment{#2}{s m}{%
% 		\myenv{##2}{##1}
% 			\ifboolexpr{bool {public} and test {\IfBooleanTF{##1}}}
% 			{} % True
% 			\bgroup% False
% 				\booltrue{#2Found}%
% 				\subsection{##2}
% 		}%
% 		%% BODY
% 		{%
% 			\egroup
% 		}%
% 	}{%
% 		\endcollect%
% 	}



\NewEnviron{myenv}[4]{% %% könnte man vmtl. auch einspaaren, war nur ein versuch
	\edef\b\BODY %% könnte man vmtl. auch einspaaren, war nur ein versuch
	\ifboolexpr{bool {public} and test {\IfBooleanTF{#4}}}%
	{} % True
	{%
		\begin{collect}{#2}%
			\booltrue{#1}%
			\subsection{#3}%
			\b%
		\end{collect}%
	}%
}

\NewDocumentCommand\bla{m m m m}{
	\newbool{#1Found}
	\newbool{#2Found}
	\definecollection{#1Collection}
	\definecollection{#2Collection}
	
	\NewDocumentEnvironment{#2}{s m}{%
		\myenv{#2Found}{#2Collection}{##2}{##1}%
	}{%
		\endmyenv%
	}


	\global\expandafter\NewDocumentCommand\csname#1\endcsname{s o m}{
		\ifboolexpr{bool {public} and test {\IfBooleanTF{##1}}}{}{%
			\IfNoValueTF{##2}{%
				\booltrue{#1Found}%
				\begin{collect}{#1Collection}{}{}%
					\item {##3}
				\end{collect}%
			}%
			{\begin{#2}{##2}##3\end{#2}}
		}
	}


	\global\expandafter\NewDocumentCommand\csname make#3\endcsname{}{
		\section{#4}
		\includecollection{#2Collection}
		\ifbool{#1Found}{%
			\ifbool{#2Found}%
			{\subsection{Sonstiges}}{}%
			%
			\begin{itemize}
				\includecollection{#1Collection}
			\end{itemize}
		}{Keine was Punkte}
	}
}


%% WAS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\bla{was}{WAS}{Was}{WAS}

%% POST %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\bla{post}{POST}{Post}{(Elektronische) Post}

%% Diskusion %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\bla{diskussion}{DISKUSSION}{Discussions}{Diskussion}


%% Berichte %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\bla{bericht}{BERICHT}{Reports}{Berichte}

\NewDocumentCommand\berichtFakRat{m}{
	\bericht{Fakultätsrat #1}
}

%% Anträge %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\definecollection{applicationCollection}

\NewDocumentEnvironment{ANTRAG}{m m}{%
	\collect{applicationCollection}{
		\subsection{#2}
	}{% BODY
		\edef\status{#1}
		\ifdefstring{\status}{angenommen}{\par $\Rightarrow$ Der Antrag wurde einstimmig angenommen.}{
		\ifdefstring{\status}{abgelehnt}{\par $\Rightarrow$ Für den Antrag konnte kein Konsens gefunden werden.}{
		\PackageError{mypackage}{you did it wrong}{help text}\stop
		}}
	}
}{\endcollect}

\NewDocumentCommand\antrag{m m G{}}{%
	\begin{ANTRAG}{#1}{#2}#3\end{ANTRAG}%
}

\NewDocumentCommand\transponderAntrag{m}{
	\antrag{angenommen}{#1 bekommt einen Transponder}
}

\NewDocumentCommand\accountAntrag{m}{
	\antrag{angenommen}{#1 bekommt einen Account}
}

\NewDocumentCommand\makeApplications{}{
	\section{Anträge}
	\includecollection{applicationCollection}
}

%% Date %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\renewdb{dateDb}

\NewDocumentCommand\termin{m m}{
	\DTLnewrow{dateDb}%
	\DTLnewdbentry{dateDb}{what}{#2}%
	\DTLnewdbentry{dateDb}{when}{#1}%
}

\NewDocumentCommand\makeDates{}{
	\section{Anstehende Termine}
	\DTLsort{when}{dateDb}%
	%
	\begin{itemize}
		\DTLforeach*{dateDb}{\theWhat=what,\theWhen=when}{%
			\item \textbf{\theWhen}\\\theWhat
		}%
	\end{itemize}
}

%% ToDo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\renewdb{todoDb}

\NewDocumentCommand\todo{o m d() o}{
	\edef\where{\thesubsection}%
	\par\emph{\IfNoValueTF{#1}{ToDo: }{ToDo \checkmark:}}#2 (#3)%
	\IfNoValueTF{#4}{}{\\\emph{Bis #4}}%
	\DTLnewrow{todoDb}%
	\DTLnewdbentry{todoDb}{what}{#2}%
	\DTLnewdbentry{todoDb}{who}{#3}%
	\DTLnewdbentry{todoDb}{where}{\where}%
	%
	\IfNoValueTF{#4}%
	{}%
	{%
		\DTLnewdbentry{todoDb}{until}{#4}%
		\IfNoValueTF{#1}{\termin{#4}{Deadline für #3: #2 (siehe \where)}}{}%
	}%
	\IfNoValueTF{#1}{}{\DTLnewdbentry{todoDb}{done}{#1}}%
}

\NewDocumentCommand\makeTodo{}{
	\section{ToDo}
	%\def\lastWho
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


%% Pro/Con %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

%% Anwesend %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\renewdb{anwesendDb}
\renewdb{modDb}
\renewdb{protDb}

\DTLaddcolumn{anwesendDb}{name}
\DTLaddcolumn{anwesendDb}{from}
\DTLaddcolumn{anwesendDb}{to}
\DTLaddcolumn{modDb}{name}
\DTLaddcolumn{modDb}{from}
\DTLaddcolumn{modDb}{to}
\DTLaddcolumn{protDb}{name}
\DTLaddcolumn{protDb}{from}
\DTLaddcolumn{protDb}{to}

\NewDocumentCommand\anwesend{o d() m d()}{
	\edef\type{#1}
	
	\IfNoValueTF{#1}{
		\def\dbName{anwesendDb}
	}{
		\ifdefstring{\type}{leitung}{\def\dbName{modDb}}{%
		\ifdefstring{\type}{protokoll}{\def\dbName{protDb}}{%
		\PackageError{mypackage}{you did it wrong}{help text}\stop
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
			\DTLifnull{\theTo}{}{ (Bis \theTo Uhr)}%
		}{ %
			(Ab \theFrom \DTLifnull{\theTo}{}{ bis \theTo} Uhr)%
		}%
	}%
}


\renewcommand*{\othersectionlevelsformat}[1]{%
	\makebox[0pt][r]{%
	\color{black!45}{\csname the#1\endcsname}\enskip\hskip .3cm}%
}

\def\beginn#1{\def\theStart{#1}}
\def\ende#1{\def\theEnd{#1}}

\def\ifint#1{\ifbool{public}{}{#1}}
\def\ifext#1{\ifbool{public}{#1}{}}
\def\INT#1{\ifbool{public}{}{#1}}




\NewDocumentCommand\sitzung{m}{
	\ifbool{public}%
	{\subtitle{Oeffentliches Protokoll}}%
	{\subtitle{\emph{Internes} Protokoll}}
	\title{Fachschaftssitzung}
	\date{\vspace{-1cm}#1}
	
	\begin{document}
		\setcounter{section}{-1}
		\setcounter{tocdepth}{0}
		\maketitle
		
% 		\ifboolexpr{bool {public} }{T}{F}
% 		\ifbool{public}{T}{F}
		
		\begin{description}
			\ifint{\item[Anwesend] \personlist{anwesendDb}}
			\ifint{\item[Leitung] \personlist{modDb}}
			\ifint{\item[Protokoll] \personlist{protDb}}
			\item[Beginn] \theStart
			\item[Ende] \theEnd
		\end{description}
		
		\section{Sitzungsleitung / Protokoll}
		Die Vorschläge zur Sitzungleitung und Protokollanten wurde angenommen.
		
		\makePost
		
		\section{Stand Projekte von letzter Woche}
		\makeReports
		\makeApplications
		\makeDiscussions
		\makeWas
		\appendix
		\makeDates
		\makeTodo
	\end{document}
}
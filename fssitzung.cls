\ProvidesClass{fssitzung}[2015/05/09 Fachschaftssitzungs class by GAF]
\LoadClass[a4paper,parskip,fontsize=9pt,DIV=12]{scrartcl}

\usepackage{iftex}

\ifPDFTeX
			\usepackage[utf8]{inputenc}
			\usepackage[ngerman]{babel}
			\usepackage[T1]{fontenc}
\else
	\ifLuaTeX
			\usepackage[ngerman]{babel}
			\usepackage[pdftex]{graphicx} % graphix always before hyperref
			\usepackage[pdftex,hidelinks]{hyperref}
	\else
	% don't switch the order: github.com/reutenauer/polyglossia/issues/50
		\ifXeTeX
			\usepackage{polyglossia}
			\setdefaultlanguage[babelshorthands=true]{german}
			\usepackage{xunicode} % loads graphicx so load it before hyperref
			\usepackage[xetex,hidelinks]{hyperref}
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

\RequirePackage[compact]{titlesec}
\titlespacing{\section}{0pt}{*0}{*0}
\titlespacing{\subsection}{0pt}{*0}{*0}
\titlespacing{\subsubsection}{0pt}{*0}{*0}

\newtoggle{public}

\def\beginn#1{\def\theStart{#1}}
\def\ende#1{\def\theEnd{#1}}
\def\ifint#1{\iftoggle{public}{}{#1}}
\def\ifext#1{\iftoggle{public}{#1}{}}

\def\defClearCollection#1{%
	\definecollection{#1}%
	\begin{collect}{#1}{}{}\end{collect}}

\expandafter\ifstrequal\expandafter{\jobname}{private}%
{\togglefalse{public}}
{\toggletrue{public}}


%%%%%%%%%%%%% Was/Post/Berichte/Diskussion %%%%%%%%%%%%%
\defClearCollection{ignore}

\NewDocumentCommand\makeCommands{m m m m m}{
	\defClearCollection{#1CollectionC}
	\defClearCollection{#2CollectionE}
	
	\newbool{#1FoundC}
	\newbool{#2FoundE}

	\DeclareDocumentEnvironment{#2}{s m}{%
		\ifboolexpr{togl{public} and test{\IfBooleanTF ##1}}
		{\@nameuse{collect}{ignore}{}{}}%	else
		{
			\@nameuse{collect}{#2CollectionE}{}{}
				\booltrue{#2FoundE}
				\subsection{##2}
		}
	}
	{
		\@nameuse{endcollect}
	}
	
	%\newenvironment{#2}[1]{
	%	\booltrue{#2FoundE}
	%	\@nameuse{collect}{#2CollectionE}{}{}
	%		\subsection{##1}
	%}
	%{
	%	\@nameuse{endcollect}
	%}
	%
	%\newenvironment{#2*}[1]{%
	%	\booltrue{#2FoundE}
	%	\iftoggle{public}%
	%	{\@nameuse{collect}{ignore}{}{}}% else
	%	{
	%		\booltrue{#2FoundE}
	%		\@nameuse{collect}{#2CollectionE}{}{}
	%			\subsection{##1}
	%	}
	%}
	%{
	%	\@nameuse{endcollect}
	%}
	
	
	\expandafter\NewDocumentCommand\csname #1\endcsname{s o m}{
		\ifboolexpr{togl{public} and test{\IfBooleanTF ##1}}{}%	else
		{
			\IfNoValueTF{##2}{%
				\booltrue{#1FoundC}
				\begin{collect}{#1CollectionC}{}{}
					\item ##3
				\end{collect}
			}
			{%
				\begin{#2}{##2}
					##3
				\end{#2}
			}
		}
	}
	
	\expandafter\NewDocumentCommand\csname make#3\endcsname{}{
		\section{#4}
		\includecollection{#2CollectionE}
		\ifbool{#1FoundC}{%
			\ifbool{#2FoundE}{\subsection{Sonstiges}}{}
			\begin{itemize}
				\includecollection{#1CollectionC}
			\end{itemize}
		}{
			\ifbool{#2FoundE}{}{Keine #5.}
		}
	}
}


%%% commands \was and \makeWas; environment WAS %%%
%{<Name Befehl>}{<Name Umgebung>}{<makeName>}{<Überschrift>}{<Bezeichnung in Text>}
\makeCommands{was}{WAS}{Was}{WAS}{WAS Punkte}

%%% commands \post and \makePost; environment POST %%%
\makeCommands{post}{POST}{Post}{(elektronische) Post}{relevante Post}

%%% commands \diskussion and \makeDiscussions; environment DISKUSSION %%%
\makeCommands{diskussion}{DISKUSSION}{Discussions}{Diskussion}{Diskussion}

%%% commands \bericht and \makeReports; environment BERICHT %%%
\makeCommands{bericht}{BERICHT}{Reports}{Berichte}{Berichte}

\NewDocumentCommand\berichtFakRat{m}{
	\bericht{Fakultätsrat #1}
}


%%%%%%%%%%%%% Anträge %%%%%%%%%%%%%

\defClearCollection{applicationCollection}
\newbool{antragFound}


\NewDocumentEnvironment{ANTRAG}{m m}{%
	\collect{applicationCollection}{
		\subsection{#2}
		\booltrue{antragFound}
	}{% BODY
		\edef\status{#1}
		\ifdefstring{\status}{angenommen}{\par $\Rightarrow$ Der Antrag wurde einstimmig angenommen.}{
		\ifdefstring{\status}{abgelehnt}{\par $\Rightarrow$ Für den Antrag konnte kein Konsens gefunden werden.}{
		\PackageError{fssitzung}{Ungültiger Status}{Das erste Argument von \\ANTRAG und \\antrag muss "angenommen", "abgelehnt" oder leer sein.}\stop
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
	\ifbool{antragFound}{}{Keine Anträge.}
}


%%%%%%%%%%%%% Date %%%%%%%%%%%%%

\DTLnewdb{dateDb}
\DTLaddcolumn{dateDb}{when}
\newbool{dateFound}

\NewDocumentCommand\termin{m m}{
	\booltrue{dateFound}
	\DTLnewrow{dateDb}%
	\DTLnewdbentry{dateDb}{what}{#2}%
	\DTLnewdbentry{dateDb}{when}{#1}%
}

\NewDocumentCommand\makeDates{}{
	\ifbool{dateFound}{
		\section{Anstehende Termine}
		\DTLsort{when}{dateDb}%
		%
		\begin{itemize}
			\DTLforeach*{dateDb}{\theWhat=what,\theWhen=when}{%
				\item \textbf{\theWhen}\\\theWhat
			}%
		\end{itemize}
	}{}
}


%%%%%%%%%%%%% ToDo %%%%%%%%%%%%%

\DTLnewdb{todoDb}

\NewDocumentCommand\todo{o m d() o}{
	\DTLifdbempty{todoDb}{}{
		\DTLaddcolumn{todoDb}{who}
		\DTLaddcolumn{todoDb}{where}
		\DTLaddcolumn{todoDb}{until}
		\DTLaddcolumn{todoDb}{done}
	}
	\edef\where{\thesubsection}%
	%\par\emph{\IfNoValueTF{#1}{ToDo: }{ToDo \checkmark: }}#2 (#3)%
	\par\emph{ToDo: }#2 (#3) \IfNoValueTF{#1}{}{ \checkmark}%
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
	
	\DTLifdbempty{todoDb}{}{
		\section{ToDo}
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
			\DTLifnull{\theTo}{}{ (Bis {\theTo} Uhr)}%
		}{ %
			(Ab \theFrom \DTLifnull{\theTo}{}{ bis \theTo} Uhr)%
		}%
	}%
}


%%%%%%%%%%%%% Dokumenterzeugung %%%%%%%%%%%%%

\NewDocumentCommand\sitzung{m}{
	\iftoggle{public}
	{	\subtitle{Öffentliches Protokoll}		}
	{	\subtitle{\emph{Internes} Protokoll}	}
	\title{Fachschaftssitzung}
	\date{\vspace{-1cm}#1}
	
	\begin{document}
		\setcounter{section}{-1}
		\setcounter{tocdepth}{0}
		\maketitle
		
		\begin{description}
			\ifint{\item[Anwesend] \personlist{anwesendDb}}
			\ifint{\item[Leitung] \personlist{modDb}}
			\ifint{\item[Protokoll] \personlist{protDb}}
			\item[Beginn] \theStart
			\item[Ende]  \theEnd
		\end{description}
		
		\section{Sitzungsleitung / Protokoll}
		Die Vorschläge zu Sitzungsleitung und Protokollanten wurden angenommen.
		
		\makePost
		
		%\section{Stand Projekte von letzter Woche}
		\makeReports
		\makeApplications
		\makeDiscussions
		\makeWas
		\appendix
		\makeDates
		\makeTodo
	\end{document}
}
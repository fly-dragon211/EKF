%DRAWLABEL Draw scalable text.
%   DRAWLABEL(X,STR,SCALE,OFFSET,COLOR) draws scalable text STR at
%   pose X = [x; y; theta] imitating the OCR font. With SCALE = 1,
%   the height of the letters is 1 meter. OFFSET shifts the text in
%   [m] from the x,y position in postive x- and y-direction. COLOR
%   is either a [r g b]-vector or a color string such as 'r' or 'g'.
%
%   Currently, the following characters are implemented: 0,1,2,3,4,
%   5,6,7,8,9,W,R,S,E,F,M,P
%
%   H = DRAWLABEL(...) returns a column vector of handles to all
%   line objects of the drawing, one handle per line.
%
%   See also TEXT.

% v.1.0, 09.11.02, Kai Arras, ASL-EPFL
% v.1.1, Nov.2003, Kai Arras, CAS-KTH: minor modifications


function h = drawlabel(x,str,scale,offset,color);

% Constants
XSQUEEZE = 0.6;           % scale x for non-square letters
XKERNING = 0.9;           % distance between letters in x
RX       = 0.5;           % round-corner-factor
RY       = RX*XSQUEEZE;   % account for squeeze in x

% 1. Fill in point and lengths-vector
n = length(str);
xtmp = x(1); y = x(2); theta = x(3); x = xtmp;
points = [];
for i = 1:n,
  switch str(i),
  case '0',
    x_vec = [RX,4-RX,4 ,4   ,4-RX,RX,0   ,0 ,RX];
    y_vec = [0 ,0   ,RY,4-RY,4   ,4 ,4-RY,RY,0 ];
  case '1',
    x_vec = [0,4,4,4,2,2,0];
    y_vec = [0,0,1,0,0,4,4];
  case '2',
    x_vec = [4,0,0   ,RX,4-RX,4   ,4   ,4-RX,0];
    y_vec = [0,0,2-RY,2 ,2   ,2+RY,4-RY,4   ,4];
  case '3',
    x_vec = [0,4-RX,4 ,4   ,4-RX,1,4-RX,4   ,4   ,4-RX,0];
    y_vec = [0,0   ,RY,2-RY,2   ,2,2   ,2+RY,4-RY,4   ,4];
  case '4',
    x_vec = [3,3,3  ,4  ,0  ,0];
    y_vec = [0,3,1.5,1.5,1.5,4];
  case '5',
    x_vec = [0 ,RX,4-RX,4 ,4   ,4-RX,1,1,4];
    y_vec = [RY,0 ,0   ,RY,2-RY,2   ,2,4,4];
  case '6',
    x_vec = [1,0,0 ,RX,4-RX,4 ,4     ,4-RX,0  ];
    y_vec = [4,4,RY,0 ,0   ,RY,1.7-RY,1.7 ,1.7];
  case '7',
    x_vec = [2,2  ,4,4,0,0  ];
    y_vec = [0,1.7,3,4,4,3.6];
  case '8',
    x_vec = [RX,0   ,0 ,RX,4-RX,4 ,4   ,4-RX,RX,1,1   ,1+RX,3-RX,3   ,3];
    y_vec = [2 ,2-RY,RY,0 ,0   ,RY,2-RY,2   ,2 ,2,4-RY,4   ,4   ,4-RY,2];
  case '9',
    x_vec = [3,4,4   ,4-RX,RX,0   ,0     ,RX ,4  ];
    y_vec = [0,0,4-RY,4   ,4 ,4-RY,2.3+RY,2.3,2.3];
  case 'W',
    x_vec = [0,0   ,RX,2-RX,2 ,2  ,2, 2+RX,4-RX,4   ,4];
    y_vec = [4,2*RY,0 ,0   ,RY,2.8,RY,0   ,0   ,2*RY,4];
  case 'R',
    x_vec = [0,0,4-RX,4   ,4     ,4-RX,0  ,0.5,4];
    y_vec = [0,4,4   ,4-RY,2.5+RY,2.5 ,2.5,2.5,0];
  case 'S',
    x_vec = [0  ,0 ,RX,4-RX,4 ,4  ,0  ,0   ,RX,4-RX,4   ,4  ];
    y_vec = [0.7,RY,0 ,0   ,RY,0.7,3.3,4-RY,4 ,4   ,4-RY,3.3];
  case 'E',
    x_vec = [4,0,0,2.3,0,0,4];
    y_vec = [0,0,2,2  ,2,4,4];
  case 'F',
    x_vec = [0,0  ,2.3,0  ,0,4];
    y_vec = [0,2.5,2.5,2.5,4,4];
  case 'M',
    x_vec = [0,0,0.5,2  ,2  ,2  ,3.5,4,4];
    y_vec = [0,4,4  ,2.8,2.5,2.8,4  ,4,0];
  case 'P',
    x_vec = [0,0,4-RX,4   ,4     ,4-RX,0  ];
    y_vec = [0,4,4   ,4-RY,1.8+RY,1.8 ,1.8];
  otherwise
    disp(['drawlabel: Warning: Letter "',str(i),'" not implemented']);
  end;
  x_vec = x_vec + 4*offset/(scale*XSQUEEZE);
  y_vec = y_vec + 4*offset/scale;
  if ~isempty(points),
    % '/4': normalize to 1; 'i-1' letter kerning
    points  = [points(1,:), x_vec/4*XSQUEEZE+XKERNING*(i-1); points(2,:), y_vec/4];
    lengths = [lengths, length(x_vec)];
  else
    points  = [x_vec*XSQUEEZE+XKERNING*(i-1); y_vec]/4;   % holds all points
    lengths = length(x_vec);  % holds the number of points of each letter
  end;
end;

% 2. Scale, translate and rotate
R = [cos(theta) -sin(theta); sin(theta) cos(theta)];
T = [x; y]*ones(1,length(points));
points = R*scale*points + T;

% 3. Plot letter-by-letter
istart = 1; h = [];
for i = 1:n,
  iend = istart + lengths(i) - 1;
  hi = plot(points(1,istart:iend),points(2,istart:iend),'Color',color);
  istart = iend + 1;
  h = cat(1,h,hi);
end;

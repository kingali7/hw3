package Position;

sub new{
   my $class = shift;
   my $self = {
      r => shift,
      c => shift,
   };	
   bless $self, $class;
   return $self; 
}

sub getC{
   my( $self ) = @_;
   return $self->{r};
}

sub getR{
   my( $self ) = @_;
   return $self->{c};
}

sub setC{
   my ( $self, $c ) = @_;
   $self->{c} = $c if defined($c);
}

sub setR{
   my ( $self, $r ) = @_;
   $self->{r} = $r if defined($r);
}

package Cell;

sub new{
   my $class = shift;
   my $self = {
      pos => shift,
      content => shift,
      explored => shift,
   };	
   bless $self, $class;
   return $self;
}

sub setExplored{
   my ( $self, $explored ) = @_;
   $self->{explored} = $explored if defined($explored);
}

sub getExplored{
   my( $self ) = @_;
   return $self->{explored};
}

sub setContent{
   my ( $self, $content ) = @_;
   $self->{content} = $content if defined($content);
}

sub getContent{
   my( $self ) = @_;
   return $self->{content};
}

sub setPos{
   my ( $self, $pos ) = @_;
   $self->{pos} = $pos if defined($pos);
}

sub getPos{
   my( $self ) = @_;
   return $self->{pos};
}

sub isAvailable{
   my( $self ) = @_;
   if ( $self->{explored} == 1 ) {
      return 1;    
   };
   if ( $self->{explored} == 0 ) {
      return 0;     
   };
}

package Maze;
our @map;

sub new{
   my $class = shift;
   my $self = {
      height => shift,
      width => shift,
      destPos => shift,};
   bless $self, $class;
   return $self;
}

sub getHeight{
   my( $self ) = @_;
   return $self->{height};
}

sub getWidth{
   my( $self ) = @_;
   return $self->{width};
}

sub explore{
   my ( $self, $pos ) = @_;
   my $row = $pos->getR();
   my $col = $pos->getC();
   my $cell = $map[$row][$col];
   $cell->setExplred(1); 
}

sub getCell{
   my ( $self, $pos ) = @_;
   my $row = $pos->getR();
   my $col = $pos->getC();
   my $cell = $map[$row][$col];
   return $cell;
}

sub setCell{
   my ( $self, $pos, $cell ) = @_;
   my $row = $pos->getR();
   my $col = $pos->getC();
   $map[$row][$col] = $cell
}

sub getCellContent{
   my ( $self, $pos ) = @_;
   my $row = $pos->getR();
   my $col = $pos->getC();
   my $cell = $map[$row][$col];
   return $cell->getContent()
}

sub setCellContent{
   my ( $self, $pos, $value ) = @_;
   my $row = $pos->getR();
   my $col = $pos->getC();
   my $cell = $map[$row][$col];
   $cell->setContent($value)
}

sub isAvailable{
   my ( $self, $pos ) = @_;
   my $row = $pos->getR();
   my $col = $pos->getC();
   my $cell = $map[$row][$col];
   if( $row <= $self->getHeight() && $col <= $self->getWidth()){
      if($cell->isAvailable() == 1){
         return 1;
      } else {
         return -1;
      }
   }
   return 0;
}

sub reachDest{
   my ( $self, $pos, ) = @_;
   if($pos == $self->{destPos}){
      return 1; 
   }
   return 0; 
}

sub displayMaze{
  my $self = shift;
  my $h = $self->getHeight();
  my $w = $self->getWidth();

  print "Current Maze > \n\n";
  my $indent = "\t\t\t";
  print "$indent   |";
  for(my $j=0; $j < $w; $j++){
    print " $j |";
  }
  print "\n$indent";
  for(my $j=0; $j < $w+1; $j++){
    print "----";
  }
  print "\n";
  for(my $i=0; $i < $h; $i++){
    print "$indent $i |";
    for(my $j=0; $j < $w; $j++){
      my $cell = $map[$i][$j];
      my $ch = $cell->{content};
      if($cell->getExplored() eq 1){
        if($ch ne "*"){
          print " $ch |";
        }
        else{
          print "   |";
        }
      }
      else{
        print " ? |";
      }
    }
    print "\n$indent";
    for(my $j=0; $j < $w+1; $j++){
      print "----";
    }
    print "\n";
  }
  print "\n--\n";
}

sub loadMaze{
  my ($self, $fh) = @_;

  my $row = <$fh>;
  chomp $row;
  my @maze_hw = split / /, $row;
  my ($h, $w) = (int($maze_hw[0]), int($maze_hw[1]));

  my ($end_h, $end_w) = (0, 0);
  my @coords = (0, 0, 0, 0);
  for(my $i=0; $i < $h; $i++){
    $row = <$fh>;
    chomp $row;
    for(my $j=0; $j < $w; $j++){
      my $ch = substr($row, $j, 1);
      my $cell = Cell->new();
      if($ch eq 'O'){
        ($end_h, $end_w) = ($i, $j);
      }
      else{
        if($ch eq '1'){
          ($coords[0], $coords[1]) = ($i, $j);
          $ch = 'E';
        }
        else{
          if($ch eq '2'){
            ($coords[2], $coords[3]) = ($i, $j);
            $ch = 'H';
          }
        }
      }

      $cell->setContent($ch);
      my $pos = Position->new();
      $pos->setR($i);
      $pos->setC($j);
      $cell->setPos($pos);
      $map[$i][$j] = $cell;
    }
  }

  $self->{height} = $h;
  $self->{width} = $w;
  $self->{destPos}->setR($end_h);
  $self->{destPos}->setC($end_w);
  $self->{map} = \@map;
  $self->{is_empty} = 0;

  $self->explore($self->{destPos});
  return @coords;
}

package Player;

our @rshift = (1, 0, -1, 0);
our @cshift = (0, 1, 0, -1);
our $specialMovesLeft = 4;

sub new{
   my $class = shift;
   my $self = {
      name => shift,
      curPos => shift,
   };
   bless $self, $class;
   return $self;
}

sub setName{
   my ( $self, $name ) = @_;
   $self->{name} = $name if defined($name);
}

sub getName{
   my ( $self ) = @_;
   return $self->{name}
}

sub getPos{
   my ( $self ) = @_;
   return $self->{curPos}
}

sub occupy{
   my ( $self, $maze ) = @_;
   $maze->setCellContent($curPos, 1);	
}

sub leave{
   my ( $self, $maze ) = @_;
   $maze->setCellContent($curPos, 0);
}

sub move{
  my ($self, $pointTo, $maze) = @_;
  my $p = $self->next($pointTo);
  if($maze->isAvailable($p) eq 1){
    $self->leave($maze);
    my $cur_h = $self->{curPos}->getR();
    my $cur_w = $self->{curPos}->getC();
    $self->{curPos}->setR($cur_h+$rshift[$pointTo]);
    $self->{curPos}->setC($cur_w+$cshift[$pointTo]);
    $self->occupy($maze);
  }
}

sub next{
  my ($self, $pointTo) = @_;
  my $pos = Position->new();
  $pos->setR($self->getPos()->getR()+$rshift[$pointTo]);
  $pos->setC($self->getPos()->getC()+$cshift[$pointTo]);
  return $pos;
}

sub rush{
   my ($self, $pointTo, $maze) = @_;
   my $pos = $self->next($pointTo);
   while($maze->isAvailable($pos) eq 1){
     $self->move($pointTo, $maze);
     $pos = $self->next($pointTo);  
   }
}

sub throughBlocked{
   my ($self, $pointTo, $maze) = @_;
   my $pos = $self->next($pointTo);
   if($maze->isAvailable($pos) eq 0){
     my $cell = $maze->getCell($pos);
     $cell->setContent("*");
     $self->move($pointTo, $maze);
     my $pos = $self->next($pointTo);
     if($maze->isAvailable($pos) eq 0){
       $self->move($pointTo, $maze);
     }else{
         if($pointTo >= 2){
           $self->move($pointTo-2, $maze);
         }else{
            $self->move($pointTo+2, $maze);
         }
     }  
   }
}

sub teleport{
   my ($self, $maze) = @_;
   my $row = int(rand $maze->getHeight());
   my $col = int(rand $maze->getWidth());
   my $pos = Position->new();
   $pos->setR($row);
   $pos->setC($col);
   if($maze->isAvailable($pos) eq 1){
     $self->leave($maze);
     $self->{curPos}->setR($row);
     $self->{curPos}->setC($col);
     $self->occupy($maze);
   }  
}

sub makeMove{
  my ($self, $maze) = @_;
  my $p_name = $self->getName();

  if($self->{specialMovesLeft} le 0){
    print "Your (Player $p_name) moving type: normal move.\n";
    print "Your (Player $p_name) moving direction (0: S, 1: E, 2: N, 3: W) > ";
    my $d = <STDIN>;
    chomp $d;

    while($d ne "0" and $d ne "1" and $d ne "2" and $d ne "3"){
      print "The moving direction can only be 0, 1, 2, or 3, please re-input > ";
      $d = <STDIN>;
      chomp $d;
    }
    $d = int($d);
    $self->move($d, $maze);
  }
  else{
    my $scnt = $self->{specialMovesLeft};
    if($scnt > 1){
      print "You (Player $p_name) can make a normal move (unlimited) or a special move (only $scnt times left).\n";
    }
    else{
      print "You (Player $p_name) can make a normal move or a special move (only $scnt time left).\n";
    }
    print "Your (Player $p_name) moving type (0: rush, 1: through-blocked, 2: teleport, default: normal move) > ";
    my $op = <STDIN>;
    chomp $op;

    while($op ne "0" and $op ne "1" and $op ne "2" and $op ne ""){
      print "This moving type can only be 0, 1, or 2, please re-input > ";
      $op = <STDIN>;
      chomp $op;
    }

    if ($op eq ""){
      $op = "-1";
    }
    $op = int($op);

    if($op eq 2){
      $self->teleport($maze);
      $self->{specialMovesLeft}--;
    }
    else{
      print "Your (Player $p_name) moving direction (0: S, 1: E, 2: N, 3: W) > ";
      my $d = <STDIN>;
      chomp $d;

      while($d ne "0" and $d ne "1" and $d ne "2" and $d ne "3"){
        print "The moving direction can only be 0, 1, 2, or 3, please re-input > ";
        $d = <STDIN>;
        chomp $d;
      }
      $d = int($d);

      if($op eq -1){
        $self->move($d, $maze);
      }
      else{
        if($op eq 0){
          $self->rush($d, $maze);
        }
        else{
          $self->throughBlocked($d, $maze);
        }
        $self->{specialMovesLeft}--;
      }
    }
  }
}

1;

#!/usr/local/bin/perl -w

# Set this to 1 if you want to use images, otherwise 0

my $use_images = 1;

# Path and filename of your image files for yin and yang lines.

my $yin = 'yin.gif';
my $yang = 'yang.gif';

###### END USER MODIFICATION SECTION ######

my $VERSION = "1.2.1";

require 5.005;

use strict;
use XML::XPath;
use HTML::Template;
use CGI qw(header param);

print header(-type=>'text/html');

my $template = HTML::Template->new(filename=>'xml-iching.template') 
  or die;

$template->param(askme => param('askme'));

my ($main_hex,$changed_hex,$moving_lines);

# Toss three coins six times to get the lines of the 
# main hexagram and the changed hexagram.

for (my $i=0; $i<6; $i++) {
  my $line = cast();
  $main_hex .= $line; 
}

sub cast {

  # Casts three coins. Heads worth three, tails worth two.
  # Returns between 6 and 9 representing one line of the
  # hexagram:
  #   6  - x -  moving Yin
  #   7  -----  Yang
  #   8  -- --  Yin
  #   9  --o--  moving Yang

  my $line = 0;
  for (my $x=0; $x<3; $x++) {
    $line += int (rand(2)) + 2;
  }
  return $line;
}


# In the changed hexagram, moving Yin becomes Yang
# and moving Yang becomes Yin.

$changed_hex = ($moving_lines = $main_hex);
$changed_hex =~ tr/6789/9966/;
$moving_lines =~ tr/6789/1001/;
$main_hex =~ tr/6789/6969/;

# reverse moving_lines so we can use chop later
$moving_lines = reverse $moving_lines;

# Now we have the hexagrams, we need to consult the book.

my $xml_data;
while (<DATA>) { $xml_data .= $_ }
my $parser = XML::XPath->new( xml=>$xml_data );

my @values;

foreach my $pattern ($main_hex, $changed_hex) {

  my $nodeset = $parser->find( "/hexagrams/hexagram/pattern" ); 

  foreach my $node ($nodeset->get_nodelist()) {

    if ( $parser->getNodeText($node) eq $pattern ) {

      my $hexagram = $node->getParentNode();

      my %value_row;
      foreach ('title','hexnum','above','below','judgement',
               'image','extra') {
        $value_row{$_} = $parser->getNodeText(
          $parser->find("./$_",$hexagram));
      } 

      if (length($moving_lines) > 0) {
        my @lines;
        foreach my $l ($parser->find('./lines/line', $hexagram)->get_nodelist) {
          if (chop $moving_lines) {
             push @lines, { line => $parser->getNodeText($l) }
          }
        }
        $value_row{lines} = \@lines;
      }

      if ($use_images) {
        my @h;
        foreach (split //, $pattern) {
          if ($_ eq '6') { push @h, { hex_image_line => $yin } } 
          else { push @h ,{ hex_image_line => $yang } }   
        }
        $value_row{hex_image} = \@h; 
      }

      push @values, \%value_row; 

      last;
    }
  }
}

$template->param(hexagram => \@values);
print $template->output();

=head1 NAME

xml-iching

=head1 README

A perl/xml based I-Ching oracle.

Complete documentation at http://www.sfu.ca/~ajdelore/xml-iching/

=head1 PREREQUISITES

This script runs under C<strict>, and requires C<XML::XPath>
and C<CGI>.

=head1 SCRIPT CATEGORIES

  CGI
  Web

=cut


__DATA__

<hexagrams>
  <hexagram>
    <hexnum>1</hexnum>
    <pattern>999999</pattern>
    <title>Ch'ien - The Creative</title>
    <above>Ch'ien The Creative, Heaven</above>
    <below>Ch'ien The Creative, Heaven</below>
    <judgement>The Creative works sublime success, Furthering through perseverance.</judgement>
    <image>The movement of heaven is full of power. Thus the superior man makes himself strong and untiring.</image>
    <lines>
      <line>Nine at the beginning means: Hidden dragon. Do not act.</line>
      <line>Nine at the second place means: Dragon appearing in the field. It furthers one to see the great man.</line>
      <line>Nine at the third place means: All day long the superior man is creatively active. At nightfall his mind is still beset with cares. Danger. No blame.</line>
      <line>Nine at the fourth place means: Wavering flight over the depths. No blame.</line>
      <line>Nine at the fifth place means: Flying dragon in the heavens. It furthers one to see the great man.</line>
      <line>Nine at the top means: Arrogant dragon will have cause to repent.</line>
    </lines>
    <extra>When all lines are nines, it means: There appears a flight of dragons without heads. Good fortune.</extra>
  </hexagram>
  <hexagram>
    <hexnum>2</hexnum>
    <pattern>666666</pattern>
    <title>K'un - The Receptive</title>
    <above>K'un   The Receptive, Earth</above>
    <below>K'un   The Receptive, Earth</below>
    <judgement>The Receptive brings about sublime success, Furthering through the perseverance of a mare. If the superior man undertakes something and tries to lead, He goes astray; But if he follows, he finds guidance. It is favorable to find friends in the west and south, To forego friends in the east and north. Quiet perseverance brings good fortune.</judgement>
    <image>The earth's condition is receptive devotion. Thus the superior man who has breadth of character Carries the outer world.</image>
    <lines>
      <line>Six at the beginning means: When there is hoarfrost underfoot, Solid ice is not far off.</line>
      <line>Six in the second place means: Straight, square, great. Without purpose, Yet nothing remains unfurthered.</line>
      <line>Six in the third place means: Hidden lines. One is able to remain persevering. If by chance you are in the service of a king, Seek not works, but bring to completion.</line>
      <line>Six in the fourth place means: A tied-sack. No blame, no praise.</line>
      <line>Six in the fifth place means: A yellow lower garment brings supreme good fortune.</line>
      <line>Six at the top means: Dragons fight in the meadow. Their blood is black and yellow.</line>
    </lines>
    <extra>When all  lines are sixes, it means: Lasting perseverance furthers.</extra>
  </hexagram>
  <hexagram>
    <hexnum>3</hexnum>
    <pattern>966696</pattern>
    <title>Chun - Difficulty at the Beginning</title>
    <above>K'an   The Abysmal, Water</above>
    <below>Chn   The Arousing, Thunder</below>
    <judgement>Difficulty at the Beginning works supreme success, Furthering through perseverance. Nothing should be undertaken. It furthers one to appoint helpers.</judgement>
    <image>Clouds and thunder:  image of Difficulty at the Beginning. Thus the superior man Brings order out of confusion.</image>
    <lines>
      <line>Nine at the beginning means: Hesitation and hindrance. It furthers one to remain persevering. It furthers one to appoint helpers.</line>
      <line>Six in the second place means: Difficulties pile up. Horse and wagon part. He is not a robber; He wants to woo when the time comes. The maiden is chaste, She does not pledge herself. Ten years-then she pledges herself.</line>
      <line>Six in the third place means: Whoever hunts deer without the forester Only loses his way in the forest. The superior man understands the signs of the time And prefers to desist. To go on brings humiliation.</line>
      <line>Six in the fourth place means: Horse and wagon part. Strive for union. To go brings good fortune. Everything acts to further.</line>
      <line>Nine at the fifth place means: Difficulties in blessing. A little perseverance brings good fortune. Great perseverance brings misfortune.</line>
      <line>Six at the top means: Horse and wagon part. Bloody tears flow.</line>
    </lines>
  </hexagram>
  <hexagram>
    <hexnum>4</hexnum>
    <pattern>696669</pattern>
    <title>Mng - Youthful Folly</title>
    <above>Kn    Keeping Still, Mountain</above>
    <below>K'an   The Abysmal, Water</below>
    <judgement>Youthful Folly has success. It is not I who seek the young fool; The young fool seeks me. At the first oracle I inform him. If he asks two or three times, it is importunity. If he importunes, I give him no information. Perseverance furthers.</judgement>
    <image>A spring wells  at the foot of the mountain:  of Youth. Thus the superior man fosters his character By thoroughness in all that he does.</image>
    <lines>
      <line>Six at the beginning means: To make a fool develop It furthers one to apply discipline. The fetters should be removed. To go on in this way brings humiliation.</line>
      <line>Nine at the second place means: To bear with fools in kindliness brings good fortune. To know how to take women Brings good fortune. The son is capable of taking charge of the household.</line>
      <line>Six in the third place means: Take not a maiden who, when she sees a man of bronze, Loses possession of herself. Nothing furthers.</line>
      <line>Six in the fourth place means: Entangled folly brings humiliation.</line>
      <line>Six in the fifth place means: Childlike folly brings good fortune.</line>
      <line>Nine at the top means: In punishing folly It does not further one To commit transgressions. The only thing that furthers Is to prevent transgressions.</line>
    </lines>
  </hexagram>
  <hexagram>
    <hexnum>5</hexnum>
    <pattern>999696</pattern>
    <title>Hsu - Waiting (Nourishment)</title>
    <above>K'an   The Abysmal, Water</above>
    <below>Ch'ien The Creative, Heaven</below>
    <judgement>Waiting. If you are sincere, You have light and success. Perseverance brings good fortune. It furthers one to cross the great water.</judgement>
    <image>Clouds rise to heaven: image of Waiting. Thus the superior man eats and drinks, Is joyous and of good cheer.</image>
    <lines>
      <line>Nine at the beginning means: Waiting in the meadow. It furthers one to abide in what endures. No blame.</line>
      <line>Nine at the second place means: Waiting on the sand. There is some gossip. The end brings good fortune.</line>
      <line>Nine at the third place means: Waiting in the mud Brings about the arrival of the enemy.</line>
      <line>Six in the fourth place means: Waiting in blood. Get out of the pit.</line>
      <line> Nine at the fifth place means: Waiting at meat and drink. Perseverance brings good fortune.</line>
      <line>Six at the top means: One falls into the pit. Three uninvited guests arrive. Honor them, and in the end there will be good fortune.</line>
    </lines>
  </hexagram>
  <hexagram>
    <hexnum>6</hexnum>
    <pattern>696999</pattern>
    <title>Sung - Conflict</title>
    <above>Ch'ien The Creative, Heaven</above>
    <below>K'an   The Abysmal, Water</below>
    <judgement>Conflict. You are sincere And are being obstructed. A cautious halt halfway brings good fortune. Going through to the end brings misfortune. It furthers one to see the great man. It does not further one to cross the great water.</judgement>
    <image>Heaven and water go their opposite ways:  image of Conflict. Thus in all his transactions the superior man Carefully considers the beginning.</image>
    <lines>
      <line>Six at the beginning means: If one does not perpetuate the affair, There is a little gossip. In the end, good fortune comes.</line>
      <line>Nine at the second place means: One cannot engage in conflict; One returns home, gives way. The people of his town, Three hundred households, Remain free of guilt.</line>
      <line>Six in the third place means: To nourish oneself on ancient virtue induces perseverance. Danger. In the end, good fortune comes. If by chance you are in the service of a king, Seek not works.</line>
      <line>Nine at the fourth place means: One cannot engage in conflict. One turns back and submits to fate, Changes one's attitude, And finds peace in perseverance. Good fortune.</line>
      <line>Nine at the fifth place means: To contend before him Brings supreme good fortune.</line>
      <line>Nine at the top means: Even if by chance a leather belt is bestowed on one, By the end of a morning It will have been snatched away three times.</line>
    </lines>
  </hexagram>
  <hexagram>
    <hexnum>7</hexnum>
    <pattern>696666</pattern>
    <title>Shih - The Army</title>
    <above>K'un   The Receptive, Earth</above>
    <below>K'an   The Abysmal, Water</below>
    <judgement>The Army. The army needs perseverance And a strong man. Good fortune without blame.</judgement>
    <image>In the middle of the earth is water:  image of the Army. Thus the superior man increases his masses By generosity toward the people.</image>
    <lines>
      <line>Six at the beginning means: An army must set forth in proper order. If the order is not good, misfortune threatens.</line>
      <line>Nine at the second place means: In the midst of the army. Good fortune. No blame. The king bestows a triple decoration.</line>
      <line>Six in the third place means: Perchance the army carries corpses in the wagon. Misfortune.</line>
      <line>Six in the fourth place means: The army retreats. No blame.</line>
      <line>Six in the fifth place means: There is game in the field. It furthers one to catch it. Without blame. Let the eldest lead the army. The younger transports corpses; Then perseverance brings misfortune.</line>
      <line>Six at the top means: The great prince issues commands, Founds states, vests families with fiefs. Inferior people should not be employed.</line>
    </lines>
  </hexagram>
  <hexagram>
    <hexnum>8</hexnum>
    <pattern>666696</pattern>
    <title>Pi - Holding Together [Union]</title>
    <above>K'an   The Abysmal, Water</above>
    <below>K'un   The Receptive, Earth</below>
    <judgement>Holding Together brings good fortune. Inquire of the oracle once again Whether you possess sublimity, constancy, and perseverance; Then there is no blame. Those who are uncertain gradually join. Whoever comes too late Meets with misfortune.</judgement>
    <image>On the earth is water:  image of Holding Together. Thus the kings of antiquity Bestowed the different states as fiefs And cultivated friendly relations With the feudal lords.</image>
    <lines>
      <line>Six at the beginning means: Hold to him in truth and loyalty; This is without blame. Truth, like a full earthen bowl: Thus in the end Good fortune comes from without.</line>
      <line>Six in the second place means: Hold to him inwardly. Perseverance brings good fortune.</line>
      <line>Six in the third place means: You hold together with the wrong people.</line>
      <line>Six in the fourth place means: Hold to him outwardly also. Perseverance brings good fortune.</line>
      <line>Nine at the fifth place means: Manifestation of holding together. In the hunt the king uses beaters on three sides only And foregoes game that runs off in front. The citizens need no warning. Good fortune.</line>
      <line>Six at the top means: He finds no head for holding together. Misfortune.</line>
    </lines>
  </hexagram>
  <hexagram>
    <hexnum>9</hexnum>
    <pattern>999699</pattern>
    <title>Hsiao Ch'u - The Taming Power of the Small</title>
    <above>Sun    The Gentle, Wind</above>
    <below>Ch'ien The Creative, Heaven</below>
    <judgement>The Taming Power of the Small Has success. Dense clouds, no rain from our western region.</judgement>
    <image>The wind drives across heaven:  image of the Taming Power of the Small. Thus the superior man Refines the outward aspect of his nature.</image>
    <lines>
      <line>Nine at the beginning means: Return to the way. How could there be blame in this? Good fortune.</line>
      <line>Nine at the second place means: He allows himself to be drawn into returning. Good fortune.</line>
      <line>Nine at the third place means: The spokes burst out of the wagon wheels. Man and wife roll their eyes. </line>
      <line>Six in the fourth place means: If you are sincere, blood vanishes and fear gives way. No blame.</line>
      <line>Nine at the fifth place means: If you are sincere and loyally attached, You are rich in your neighbor.</line>
      <line>Nine at the top means: The rain comes, there is rest. This is due to the lasting effect of character. Perseverance brings the woman into danger. The moon is nearly full. If the superior man persists, Misfortune comes.</line>
    </lines>
  </hexagram>
  <hexagram>
    <hexnum>10</hexnum>
    <pattern>996999</pattern>
    <title>Lu - Treading [Conduct]</title>
    <above>Ch'ien The Creative, Heaven</above>
    <below>Tui    The Joyous, Lake</below>
    <judgement>Treading. Treading upon the tail of the tiger. It does not bite the man. Success.</judgement>
    <image>Heaven above, the lake below: image of Treading. Thus the superior man discriminates between high and low, And thereby fortifies the thinking of the people.</image>
    <lines>
      <line>Nine at the beginning means: Simple conduct. Progress without blame.</line>
      <line>Nine at the second place means: Treading a smooth, level course. The perseverance of a dark man Brings good fortune. </line>
      <line>Six in the third place means: A one-eyed man is able to see, A lame man is able to tread. He treads on the tail of the tiger. The tiger bites the man. Misfortune. Thus does a warrior act on behalf of his great prince.</line>
      <line>Nine at the fourth place means: He treads on the tail of the tiger. Caution and circumspection Lead ultimately to good fortune.</line>
      <line>Nine at the fifth place means: Resolute conduct. Perseverance with awareness of danger.</line>
      <line>Nine at the top means: Look to your conduct and weigh the favorable signs. When everything is fulfilled, supreme good fortune comes.</line>
    </lines>
  </hexagram>
  <hexagram>
    <hexnum>11</hexnum>
    <pattern>999666</pattern>
    <title>T'ai - Peace</title>
    <above>K'un   The Receptive, Earth</above>
    <below>Ch'ien The Creative, Heaven</below>
    <judgement>Peace. The small departs, The great approaches. Good fortune. Success.</judgement>
    <image>Heaven and earth unite:  image of Peace. Thus the ruler Divides and completes the course of heaven and earth; He furthers and regulates the gifts of heaven and earth, And so aids the people.</image>
    <lines>
      <line>Nine at the beginning means: When ribbon grass is pulled up, the sod comes with it. Each according to his kind. Undertakings bring good fortune.</line>
      <line>Nine at the second place means: Bearing with the uncultured in gentleness, Fording the river with resolution, Not neglecting what is distant, Not regarding one's companions: Thus one may manage to walk in the middle.</line>
      <line>Nine at the third place means: No plain not followed by a slope. No going not followed by a return. He who remains persevering in danger Is without blame. Do not complain about this truth; Enjoy the good fortune you still possess.</line>
      <line>Six in the fourth place means: He flutters down, not boasting of his wealth, Together with his neighbor, Guileless and sincere.</line>
      <line>Six in the fifth place means: The sovereign I Gives his daughter in marriage. This brings blessing And supreme good fortune.</line>
      <line>Six at the top means: The wall falls back into the moat. Use no army now. Make your commands known within your own town. Perseverance brings humiliation.</line>
    </lines>
  </hexagram>
  <hexagram>
    <hexnum>12</hexnum>
    <pattern>666999</pattern>
    <title>P'i - Standstill [Stagnation]</title>
    <above>Ch'ien The Creative, Heaven</above>
    <below>K'un   The Receptive, Earth</below>
    <judgement>Standstill. Evil people do not further The perseverance of the superior man. The great departs; the small approaches.</judgement>
    <image>Heaven and earth do not unite:  image of Standstill. Thus the superior man falls back upon his inner worth In order to escape the difficulties. He does not permit himself to be honored with revenue.</image>
    <lines>
      <line>Six at the beginning means: When ribbon grass is pulled up, the sod comes with it. Each according to his kind. Perseverance brings good fortune and success. </line>
      <line>Six in the second place means: They bear and endure; This means good fortune for inferior people. The standstill serves to help the great man to attain success.</line>
      <line>Six in the third place means: They bear shame.</line>
      <line>Nine at the fourth place means: He who acts at the command of the highest Remains without blame. Those of like mind partake of the blessing.</line>
      <line>Nine at the fifth place means: Standstill is giving way. Good fortune for the great man. "What if it should fail, what if it should fail?" In this way he ties it to a cluster of mulberry shoots.</line>
      <line>Nine at the top means: The standstill comes to an end. First standstill, then good fortune.</line>
    </lines>
  </hexagram>
  <hexagram>
    <hexnum>13</hexnum>
    <pattern>969999</pattern>
    <title>T'ung Jn - Fellowship with Men</title>
    <above>Ch'ien The Creative, Heaven</above>
    <below>Li     The Clinging, Flame</below>
    <judgement>Fellowship with Men in the open. Success. It furthers one to cross the great water. The perseverance of the superior man furthers.</judgement>
    <image>Heaven together with fire:  image of Fellowship with Men. Thus the superior man organizes the clans And makes distinctions between things.</image>
    <lines>
      <line>Nine at the beginning means: Fellowship with men at the gate. No blame.</line>
      <line>Six in the second place means: Fellowship with men in the clan. Humiliation.</line>
      <line>Nine at the third place means: He hides weapons in the thicket; He climbs the high hill in front of it. For three years he does not rise up.</line>
      <line>Nine at the fourth place means: He climbs  on his wall; he cannot attack. Good fortune.</line>
      <line>Nine at the fifth place means: Men bound in fellowship first weep and lament, But afterward they laugh. After great struggles they succeed in meeting.</line>
      <line>Nine at the top means: Fellowship with men in the meadow. No remorse.</line>
    </lines>
  </hexagram>
  <hexagram>
    <hexnum>14</hexnum>
    <pattern>999969</pattern>
    <title>Ta Yu - Possession in Great Measure</title>
    <above>Li  The Clinging, Flame</above>
    <below>Ch'ien The Creative, Heaven</below>
    <judgement>Possession in Great Measure. Supreme success.</judgement>
    <image>Fire in heaven above:  image of Possession in Great Measure. Thus the superior man curbs evil and furthers good, And thereby obeys the benevolent will of heaven.</image>
    <lines>
      <line>Nine at the beginning means: No relationship with what is harmful; There is no blame in this. If one remains conscious of difficulty, One remains without blame.</line>
      <line>Nine at the second place means: A big wagon for loading. One may undertake something. No blame.</line>
      <line>Nine at the third place means: A prince offers it to the Son of Heaven. A petty man cannot do this.</line>
      <line>Nine at the fourth place means: He makes a difference Between himself and his neighbor. No blame.</line>
      <line>Six in the fifth place means: He whose truth is accessible, yet dignified, Has good fortune.</line>
      <line>Nine at the top means: He is blessed by heaven. Good fortune. Nothing that does not further.</line>
    </lines>
  </hexagram>
  <hexagram>
    <hexnum>15</hexnum>
    <pattern>669666</pattern>
    <title>Ch'ien - Modesty</title>
    <above>K'un   The Receptive, Earth</above>
    <below>Kn    Keeping Still, Mountain</below>
    <judgement>Modesty creates success. The superior man carries things through.</judgement>
    <image>Within the earth, a mountain: image of Modesty. Thus the superior man reduces that which is too much, And augments that which is too little. He weighs things and makes them equal.</image>
    <lines>
      <line>Six at the beginning means: A superior man modest about his modesty May cross the great water. Good fortune.</line>
      <line>Six in the second place means: Modesty that comes to expression. Perseverance brings good fortune.</line>
      <line>Nine at the third place means: A superior man of modesty and merit Carries things to conclusion. Good fortune.</line>
      <line>Six in the fourth place means: Nothing that would not further modesty In movement.</line>
      <line>Six in the fifth place means: No boasting of wealth before one's neighbor. It is favorable to attack with force. Nothing that would not further.</line>
      <line>Six at the top means: Modesty that comes to expression. It is favorable to set armies marching To chastise one's own city and one's country.</line>
    </lines>
  </hexagram>
  <hexagram>
    <hexnum>16</hexnum>
    <pattern>666966</pattern>
    <title>Yu - Enthusiasm</title>
    <above>Chn   The Arousing, Thunder</above>
    <below>K'un   The Receptive, Earth</below>
    <judgement>Enthusiasm. It furthers one to install helpers And to set armies marching.</judgement>
    <image>Thunder comes resounding out of the earth  of Enthusiasm. Thus the ancient kings made music In order to honor merit, And offered it with splendor To the Supreme Deity, Inviting their ancestors to be present.</image>
    <lines>
      <line>Six at the beginning means: Enthusiasm that expresses itself Brings misfortune.</line>
      <line>Six in the second place means: Firm as a rock. Not a whole day. Perseverance brings good fortune.</line>
      <line>Six in the third place means: Enthusiasm that looks upward creates remorse. Hesitation brings remorse.</line>
      <line>Nine at the fourth place means: The source of enthusiasm. He achieves great things. Doubt not. You gather friends around you As a hair clasp gathers the hair.</line>
      <line>Six in the fifth place means: Persistently ill, and still does not die.</line>
      <line>Six at the top means: Deluded enthusiasm. But if after completion one changes, There is no blame.</line>
    </lines>
  </hexagram>
  <hexagram>
    <hexnum>17</hexnum>
    <pattern>966996</pattern>
    <title>Sui - Following</title>
    <above>Tui    The Joyous, Lake</above>
    <below>Chn   The Arousing, Thunder</below>
    <judgement>Following has supreme success. Perseverance furthers. No blame.</judgement>
    <image>Thunder in the middle of the lake: image of Following. Thus the superior man at nightfall Goes indoors for rest and recuperation.</image>
    <lines>
      <line>Nine at the beginning means: The standard is changing. Perseverance brings good fortune. To go out of the door in company Produces deeds.</line>
      <line>Six in the second place means: If one clings to the little boy, One loses the strong man.</line>
      <line>Six in the third place means: If one clings to the strong man, One loses the little boy. Through following one finds what one seeks. It furthers one to remain persevering.</line>
      <line>Nine at the fourth place means: Following creates success. Perseverance brings misfortune. To go one's way with sincerity brings clarity. How could there be blame in this?</line>
      <line>Nine at the fifth place means: Sincere in the good. Good fortune.</line>
      <line>Six at the top means: He meets with firm allegiance And is still further bound. The king introduces him To the Western Mountain.</line>
    </lines>
  </hexagram>
  <hexagram>
    <hexnum>18</hexnum>
    <pattern>699669</pattern>
    <title>Ku - Work on What Has Been Spoiled [Decay]</title>
    <above>Kn    Keeping Still, Mountain</above>
    <below>Sun    The Gentle, Wind</below>
    <judgement>Work on What Has Been Spoiled Has supreme success. It furthers one to cross the great water. Before the starting point, three days. After the starting point, three days.</judgement>
    <image>The wind blows low on the mountain image of Decay. Thus the superior man stirs  the people And strengthens their spirit.</image>
    <lines>
      <line>Six at the beginning means: Setting right what has been spoiled by the father. If there is a son, No blame rests upon the departed father. Danger. In the end good fortune.</line>
      <line>Nine at the second place means: Setting right what has been spoiled by the mother. One must not be too persevering.</line>
      <line>Nine at the third place means: Setting right what has been spoiled by the father. There will be little remorse. No great blame.</line>
      <line>Six in the fourth place means: Tolerating what has been spoiled by the father. In continuing one sees humiliation.</line>
      <line>Six in the fifth place means: Setting right what has been spoiled by the father. One meets with praise.</line>
      <line>Nine at the top means: He does not serve kings and princes, Sets himself higher goals.</line>
    </lines>
  </hexagram>
  <hexagram>
    <hexnum>19</hexnum>
    <pattern>996666</pattern>
    <title>Lin - Approach</title>
    <above>K'un   The Receptive, Earth</above>
    <below>Tui    The Joyous, Lake</below>
    <judgement>Approach has supreme success. Perseverance furthers. When the eighth month comes, There will be misfortune.</judgement>
    <image>The earth above the lake: image of Approach. Thus the superior man is inexhaustible In his will to teach, And without limits In his tolerance and protection of the people.</image>
    <lines>
      <line>Nine at the beginning means: Joint approach. Perseverance brings good fortune.</line>
      <line>Nine at the second place means: Joint approach. Good fortune. Everything furthers.</line>
      <line>Six in the third place means: Comfortable approach. Nothing that would further. If one is induced to grieve over it, One becomes free of blame.</line>
      <line>Six in the fourth place means: Complete approach. No blame.</line>
      <line>Six in the fifth place means: Wise approach. This is right for a great prince. Good fortune.</line>
      <line>Six at the top means: Greathearted approach. Good fortune. No blame.</line>
    </lines>
  </hexagram>
  <hexagram>
    <hexnum>20</hexnum>
    <pattern>666699</pattern>
    <title>Kuan - Contemplation (View)</title>
    <above>Sun    The Gentle, Wind</above>
    <below>K'un   The Receptive, Earth</below>
    <judgement>Contemplation. The ablution has been made, But not yet the offering. Full of trust they look  to him.</judgement>
    <image>The wind blows over the earth Image of Contemplation. Thus the kings of old visited the regions of the world, Contemplated the people, And gave them instruction.</image>
    <lines>
      <line>Six at the beginning means: Boylike contemplation. For an inferior man, no blame. For a superior man, humiliation.</line>
      <line>Six in the second place means: Contemplation through the crack of the door. Furthering for the perseverance of a woman.</line>
      <line>Six in the third place means: Contemplation of my life Decides the choice Between advance and retreat.</line>
      <line>Six in the fourth place means: Contemplation of the light of the kingdom. It furthers one to exert influence as the guest of a king.</line>
      <line>Nine at the fifth place means: Contemplation of my life. The superior man is without blame. </line>
      <line>Nine at the top means: Contemplation of his life. The superior man is without blame.</line>
    </lines>
  </hexagram>
  <hexagram>
    <hexnum>21</hexnum>
    <pattern>966969</pattern>
    <title>Shih Ho - Biting Through</title>
    <above>Li     The Clinging, Flame</above>
    <below>Chn   The Arousing, Thunder</below>
    <judgement>Biting Through has success. It is favorable to let justice be administered.</judgement>
    <image>Thunder and lightning:  image of Biting Through. Thus the kings of former times made firm the laws Through clearly defined penalties.</image>
    <lines>
      <line>Nine at the beginning means: His feet are fastened in the stocks, So that his toes disappear. No blame.</line>
      <line>Six in the second place means: Bites through tender meat, So that his nose disappears. No blame.</line>
      <line>Six in the third place means: Bites on old dried meat And strikes on something poisonous. Slight humiliation. No blame.</line>
      <line>Nine at the fourth place means: Bites on dried gristly meat. Receives metal arrows. It furthers one to be mindful of difficulties And to be persevering. Good fortune.</line>
      <line>Six in the fifth place means: Bites on dried lean meat. Receives yellow gold. Perseveringly aware of danger. No blame.</line>
      <line>Nine at the top means: His neck is fastened in the wooden cangue, So that his ears disappear. Misfortune.</line>
    </lines>
  </hexagram>
  <hexagram>
    <hexnum>22</hexnum>
    <pattern>969669</pattern>
    <title>Pi - Grace</title>
    <above>Kn    Keeping Still, Mountain</above>
    <below>Li     The Clinging, Flame</below>
    <judgement>Grace has success. In small matters It is favorable to undertake something.</judgement>
    <image>Fire at the foot of the mountain Image of Grace. Thus does the superior man proceed When clearing current affairs. But he dare not decide controversial issues in this way.</image>
    <lines>
      <line>Nine at the beginning means: He lends grace to his toes, leaves the carriage, and walks. </line>
      <line>Six in the second place means: Lends grace to the beard on his chin.</line>
      <line>Nine at the third place means: Graceful and moist. Constant perseverance brings good fortune.</line>
      <line>Six in the fourth place means: Grace or simplicity? A white horse comes as if on wings. He is not a robber, He will woo at the right time.</line>
      <line>Six in the fifth place means: Grace in hills and gardens. The roll of silk is meager and small. Humiliation, but in the end good fortune. </line>
      <line>Nine at the top means: Simple grace. No blame.</line>
    </lines>
  </hexagram>
  <hexagram>
    <hexnum>23</hexnum>
    <pattern>666669</pattern>
    <title>Po - Splitting Apart</title>
    <above>Kn    Keeping Still, Mountain</above>
    <below>K'un   The Receptive, Earth</below>
    <judgement>Splitting Apart. It does not further one To go anywhere.</judgement>
    <image>The mountain rests on the earth: image of Splitting Apart. Thus those above can ensure their position Only by giving generously to those below.</image>
    <lines>
      <line>Six at the beginning means: The leg of the bed is split. Those who persevere are destroyed. Misfortune.</line>
      <line>Six in the second place means: The bed is split at the edge. Those who persevere are destroyed. Misfortune.</line>
      <line>Six in the third place means: He splits with them. No blame.</line>
      <line>Six in the fourth place means: The bed is split to the skin. Misfortune.</line>
      <line>Six in the fifth place means: A shoal of fishes. Favor comes through the court ladies. Everything acts to further. </line>
      <line>Nine at the top means: There is a large fruit still uneaten. The superior man receives a carriage. The house of the inferior man is split apart.</line>
    </lines>
  </hexagram>
  <hexagram>
    <hexnum>24</hexnum>
    <pattern>966666</pattern>
    <title>Fu - Return (The Turning Point)</title>
    <above>K'un   The Receptive, Earth</above>
    <below>Chn   The Arousing, Thunder</below>
    <judgement>Return. Success. Going out and coming in without error. Friends come without blame. To and fro goes the way. On the seventh day comes return. It furthers one to have somewhere to go.</judgement>
    <image>Thunder within the earth Image of the Turning Point. Thus the kings of antiquity closed the passes At the time of solstice. Merchants and strangers did not go about, And the ruler Did not travel through the provinces.</image>
    <lines>
      
      <line>Nine at the beginning means: Return from a short distance. No need for remorse. Great good fortune.</line>
      <line>Six in the second place means: Quiet return. Good fortune.</line>
      <line>Six in the third place means: Repeated return. Danger. No blame.</line>
      <line>Six in the fourth place means: Walking in the midst of others, One returns alone.</line>
      <line>Six in the fifth place means: Noblehearted return. No remorse.</line>
      <line>Six at the top means: Missing the return. Misfortune. Misfortune from within and without. If armies are set marching in this way, One will in the end suffer a great defeat, Disastrous for the ruler of the country. For ten years It will not be possible to attack again.</line>
    </lines>
  </hexagram>
  <hexagram>
    <hexnum>25</hexnum>
    <pattern>966999</pattern>
    <title>Wu Wang - Innocence (The Unexpected)</title>
    <above>Ch'ien The Creative, Heaven</above>
    <below>Chn   The Arousing, Thunder</below>
    <judgement>Innocence. Supreme success. Perseverance furthers. If someone is not as he should be, He has misfortune, And it does not further him To undertake anything.</judgement>
    <image>Under heaven thunder rolls: All things attain the natural state of innocence. Thus the kings of old, Rich in virtue, and in harmony with the time, Fostered and nourished all beings.</image>
    <lines>
      
      <line>Nine at the beginning means: Innocent behavior brings good fortune.</line>
      <line>Six in the second place means: If one does not count on the harvest while plowing, Nor on the use of the ground while clearing it, It furthers one to undertake something.</line>
      <line>Six in the third place means: Undeserved misfortune. The cow that was tethered by someone Is the wanderer's gain, the citizen's loss.</line>
      <line>Nine at the fourth place means: He who can be persevering Remains without blame. </line>
      <line>Nine at the fifth place means: Use no medicine in an illness Incurred through no fault of your own. It will pass of itself.</line>
      <line>Nine at the top means: Innocent action brings misfortune. Nothing furthers.</line>
    </lines>
  </hexagram>
  <hexagram>
    <hexnum>26</hexnum>
    <pattern>999669</pattern>
    <title>Ta Ch'u - The Taming Power of the Great</title>
    <above>Kn    Keeping Still, Mountain</above>
    <below>Ch'ien The Creative, Heaven</below>
    <judgement>The Taming Power of the Great. Perseverance furthers. Not eating at home brings good fortune. It furthers one to cross the great water.</judgement>
    <image>Heaven within the mountain Image of the Taming Power of the Great. Thus the superior man acquaints himself with many sayings of antiquity And many deeds of the past, In order to strengthen his character thereby.</image>
    <lines>
      <line>Nine at the beginning means: Danger is at hand. It furthers one to desist.</line>
      <line>Nine at the second place means: The axletrees are taken from the wagon.</line>
      <line>Nine at the third place means: A good horse that follows others. Awareness of danger, With perseverance, furthers. Practice chariot driving and armed defense daily. It furthers one to have somewhere to go.</line>
      <line>Six in the fourth place means: The headboard of a young bull. Great good fortune. </line>
      <line>Six in the fifth place means: The tusk of a gelded boar. Good fortune. </line>
      <line>Nine at the top means: One attains the way of heaven. Success.</line>
    </lines>
  </hexagram>
  <hexagram>
    <hexnum>27</hexnum>
    <pattern>966669</pattern>
    <title>I - The Corners of the Mouth (Providing Nourishment)</title>
    <above>Kn    Keeping Still, Mountain</above>
    <below>Chn   The Arousing, Thunder</below>
    <judgement>The Corners of the Mouth. Perseverance brings good fortune. Pay heed to the providing of nourishment And to what a man seeks To fill his own mouth with.</judgement>
    <image>At the foot of the mountain, thunder Image of Providing Nourishment. Thus the superior man is careful of his words And temperate in eating and drinking.</image>
    <lines>
      <line>Nine at the beginning means: You let your magic tortoise go, And look at me with the corners of your mouth drooping. Misfortune.</line>
      <line>Six in the second place means: Turning to the summit for nourishment, Deviating from the path To seek nourishment from the hill. Continuing to do this brings misfortune.</line>
      <line>Six in the third place means: Turning away from nourishment. Perseverance brings misfortune. Do not act thus for ten years. Nothing serves to further.</line>
      <line>Six in the fourth place means: Turning to the summit For provision of nourishment Brings good fortune. Spying about with sharp eyes Like a tiger with insatiable craving. No blame. </line>
      <line>Six in the fifth place means: Turning away from the path. To remain persevering brings good fortune. One should not cross the great water. </line>
      <line>Nine at the top means: The source of nourishment. Awareness of danger brings good fortune. It furthers one to cross the great water.</line>
    </lines>
  </hexagram>
  <hexagram>
    <hexnum>28</hexnum>
    <pattern>699996</pattern>
    <title>Ta Kuo - Preponderance of the Great</title>
    <above>Tui    The Joyous, Lake</above>
    <below>Sun    The Gentle, Wind</below>
    <judgement>Preponderance of the Great. The ridgepole sags to the breaking point. It furthers one to have somewhere to go. Success.</judgement>
    <image>The lake rises above the trees Image of Preponderance of the Great. Thus the superior man, when he stands alone, Is unconcerned, And if he has to renounce the world, He is undaunted.</image>
    <lines>
      <line>Six at the beginning means: To spread white rushes underneath. No blame. </line>
      <line>Nine at the second place means: A dry poplar sprouts at the root. An older man takes a young wife. Everything furthers.</line>
      <line>Nine at the third place means: The ridgepole sags to the breaking point. Misfortune. </line>
      <line>Nine at the fourth place means: The ridgepole is braced. Good fortune. If there are ulterior motives, it is humiliating.</line>
      <line>Nine at the fifth place means: A withered poplar puts forth flowers. An older woman takes a husband. No blame. No praise.</line>
      <line>Six at the top means: One must go through the water. It goes over one's head. Misfortune. No blame.</line>
    </lines>
  </hexagram>
  <hexagram>
    <hexnum>29</hexnum>
    <pattern>696696</pattern>
    <title>K'an - The Abysmal (Water)</title>
    <above>K'an   The Abysmal, Water</above>
    <below>K'an   The Abysmal, Water</below>
    <judgement>The Abysmal repeated. If you are sincere, you have success in your heart, And whatever you do succeeds.</judgement>
    <image>Water flows on uninterruptedly and reaches its goal Image of the Abysmal repeated. Thus the superior man walks in lasting virtue And carries on the business of teaching.</image>
    <lines>
      <line>Six at the beginning means: Repetition of the Abysmal. In the abyss one falls into a pit. Misfortune. </line>
      <line>Nine at the second place means: The abyss is dangerous. One should strive to attain small things only.</line>
      <line>Six in the third place means: Forward and backward, abyss on abyss. In danger like this, pause at first and wait, Otherwise you will fall into a pit in the abyss. Do not act in this way.</line>
      <line>Six in the fourth place means: A jug of wine, a bowl of rice with it; Earthen vessels Simply handed in through the window. There is certainly no blame in this. </line>
      <line>Nine at the fifth place means: The abyss is not filled to overflowing, It is filled only to the rim. No blame.</line>
      <line>Six at the top means: Bound with cords and ropes, Shut in between thorn-hedged prison walls: For three years one does not find the way. Misfortune.</line>
    </lines>
  </hexagram>
  <hexagram>
    <hexnum>30</hexnum>
    <pattern>969969</pattern>
    <title>Li - The Clinging, Fire</title>
    <above>Li     The Clinging, Flame</above>
    <below>Li     The Clinging, Flame</below>
    <judgement>The Clinging. Perseverance furthers. It brings success. Care of the cow brings good fortune.</judgement>
    <image>That which is bright rises twice Image of Fire. Thus the great man, by perpetuating this brightness, Illumines the four quarters of the world.</image>
    <lines>
      <line>Nine at the beginning means: The footprints run crisscross. If one is seriously intent, no blame. </line>
      <line>Six in the second place means: Yellow light. Supreme good fortune.</line>
      <line>Nine at the third place means: In the light of the setting sun, Men either beat the pot and sing Or loudly bewail the approach of old age. Misfortune.</line>
      <line>Nine at the fourth place means: Its coming is sudden; It flames up, dies down, is thrown away. </line>
      <line>Six in the fifth place means: Tears in floods, sighing and lamenting. Good fortune.</line>
      <line>Nine at the top means: The king uses him to march forth and chastise. Then it is best to kill the leaders And take captive the followers. No blame.</line>
    </lines>
  </hexagram>
  <hexagram>
    <hexnum>31</hexnum>
    <pattern>669996</pattern>
    <title>Hsien - Influence (Wooing)</title>
    <above>Tui    The Joyous, Lake</above>
    <below>Kn    Keeping Still, Mountain</below>
    <judgement>Influence. Success. Perseverance furthers. To take a maiden to wife brings good fortune.</judgement>
    <image>A lake on the mountain Image of Influence. Thus the superior man encourages people to approach him By his readiness to receive them.</image>
    <lines>
      <line>Six at the beginning means: The influence shows itself in the big toe.</line>
      <line>Six in the second place means: The influence shows itself in the calves of the legs. Misfortune. Tarrying brings good fortune.</line>
      <line>Nine at the third place means: The influence shows itself in the thighs. Holds to that which follows it. To continue is humiliating. </line>
      <line>Nine at the fourth place means: Perseverance brings good fortune. Remorse disappears. If a man is agitated in mind, And his thoughts go hither and thither, Only those friends On whom he fixes his conscious thoughts Will follow. </line>
      <line>Nine at the fifth place means: The influence shows itself in the back of the neck. No remorse.</line>
      <line>Six at the top means: The influence shows itself in the jaws, cheeks, and tongue.</line>
    </lines>
  </hexagram>
  <hexagram>
    <hexnum>32</hexnum>
    <pattern>699966</pattern>
    <title>Hng - Duration</title>
    <above>Chn   The Arousing, Thunder</above>
    <below>Sun    The Gentle, Wind</below>
    <judgement>Duration. Success. No blame. Perseverance furthers. It furthers one to have somewhere to go.</judgement>
    <image>Thunder and wind Image of Duration. Thus the superior man stands firm And does not change his direction.</image>
    <lines>
      <line>Six at the beginning means: Seeking duration too hastily brings misfortune persistently. Nothing that would further. </line>
      <line>Nine at the second place means: Remorse disappears.</line>
      <line>Nine at the third place means: He who does not give duration to his character Meets with disgrace. Persistent humiliation.</line>
      <line>Nine at the fourth place means: No game in the field.</line>
      <line>Six in the fifth place means: Giving duration to one's character through perseverance. This is good fortune for a woman, misfortune for a man.</line>
      <line>Six at the top means: Restlessness as an enduring condition brings misfortune.</line>
    </lines>
  </hexagram>
  <hexagram>
    <hexnum>33</hexnum>
    <pattern>669999</pattern>
    <title>Tun - Retreat</title>
    <above>Ch'ien The Creative, Heaven</above>
    <below>Kn    Keeping Still, Mountain</below>
    <judgement>Retreat. Success. In what is small, perseverance furthers.</judgement>
    <image>Mountain under heaven Image of Retreat. Thus the superior man keeps the inferior man at a distance, Not angrily but with reserve.</image>
    <lines>
      
      <line>Six at the beginning means: At the tail in retreat. This is dangerous. One must not wish to undertake anything. </line>
      <line>Six in the second place means: He holds him fast with yellow oxhide. No one can tear him loose.</line>
      <line>Nine at the third place means: A halted retreat Is nerve-wracking and dangerous. To retain people as men- and maidservants Brings good fortune.</line>
      <line>Nine at the fourth place means: Voluntary retreat brings good fortune to the superior man And downfall to the inferior man. </line>
      <line>Nine at the fifth place means: Friendly retreat. Perseverance brings good fortune.</line>
      <line>Nine at the top means: Cheerful retreat. Everything serves to further.</line>
    </lines>
  </hexagram>
  <hexagram>
    <hexnum>34</hexnum>
    <pattern>999966</pattern>
    <title>Ta Chuang - The Power of the Great</title>
    <above>Chn   The Arousing, Thunder</above>
    <below>Ch'ien The Creative, Heaven</below>
    <judgement>The Power of the Great. Perseverance furthers.</judgement>
    <image>Thunder in heaven above Image of the Power of the Great. Thus the superior man does not tread upon paths That do not accord with established order.</image>
    <lines>
      <line>Nine at the beginning means: Power in the toes. Continuing brings misfortune. This is certainly true.</line>
      <line>Nine at the second place means: Perseverance brings good fortune.</line>
      <line>Nine at the third place means: The inferior man works through power. The superior man does not act thus. To continue is dangerous. A goat butts against a hedge And gets its horns entangled. </line>
      <line>Nine at the fourth place means: Perseverance brings good fortune. Remorse disappears. The hedge opens; there is no entanglement. Power depends upon the axle of a big cart.</line>
      <line>Six in the fifth place means: Loses the goat with ease. No remorse.</line>
      <line>Six at the top means: A goat butts against a hedge. It cannot go backward, it cannot go forward. Nothing serves to further. If one notes the difficulty, this brings good fortune.</line>
    </lines>
  </hexagram>
  <hexagram>
    <hexnum>35</hexnum>
    <pattern>666969</pattern>
    <title>Chin - Progress</title>
    <above>Li     The Clinging, Flame</above>
    <below>K'un   The Receptive, Earth</below>
    <judgement>Progress. The powerful prince Is honored with horses in large numbers. In a single day he is granted audience three times.</judgement>
    <image>The sun rises over the earth Image of Progress. Thus the superior man himself Brightens his bright virtue.</image>
    <lines>
      <line>Six at the beginning means: Progressing, but turned back. Perseverance brings good fortune. If one meets with no confidence, one should remain calm. No mistake.</line>
      <line>Six in the second place means: Progressing, but in sorrow. Perseverance brings good fortune. Then one obtains great happiness from one's ancestress.</line>
      <line>Six in the third place means: All are in accord. Remorse disappears.</line>
      <line>Nine at the fourth place means: Progress like a hamster. Perseverance brings danger. </line>
      <line>Six in the fifth place means: Remorse disappears. Take not gain and loss to heart. Undertakings bring good fortune. Everything serves to further.</line>
      <line>Nine at the top means: Making progress with the horns is permissible Only for the purpose of punishing one's own city. To be conscious of danger brings good fortune. No blame. Perseverance brings humiliation.</line>
    </lines>
  </hexagram>
  <hexagram>
    <hexnum>36</hexnum>
    <pattern>969666</pattern>
    <title>Ming I - Darkening of the Light</title>
    <above>K'un   The Receptive, Earth</above>
    <below>Li     The Clinging, Flame</below>
    <judgement>Darkening of the Light. In adversity It furthers one to be persevering.</judgement>
    <image>The light has sunk into the earth Image of Darkening of the Light. Thus does the superior man live with the great mass: He veils his light, yet still shines.</image>
    <lines>
      <line>Nine at the beginning means: Darkening of the light during flight. He lowers his wings. The superior man does not eat for three days On his wanderings. But he has somewhere to go. The host has occasion to gossip about him. </line>
      <line>Six in the second place means: Darkening of the light injures him in the left thigh. He gives aid with the strength of a horse. Good fortune.</line>
      <line>Nine at the third place means: Darkening of the light during the hunt in the south. Their great leader is captured. One must not expect perseverance too soon.</line>
      <line>Six in the fourth place means: He penetrates the left side of the belly. One gets at the very heart of the darkening of the light, And leaves gate and courtyard. </line>
      <line>Six in the fifth place means: Darkening of the light as with Prince Chi. Perseverance furthers. </line>
      <line>Six at the top means: Not light but darkness. First he climbed  to heaven, Then he plunged into the depths of the earth.</line>
    </lines>
  </hexagram>
  <hexagram>
    <hexnum>37</hexnum>
    <pattern>969699</pattern>
    <title>Chia Jn - The Family [The Clan]</title>
    <above>Sun    The Gentle, Wind</above>
    <below>Li     The Clinging, Flame</below>
    <judgement>The Family. The perseverance of the woman furthers.</judgement>
    <image>Wind comes forth from fire Image of the Family. Thus the superior man has substance in his words And duration in his way of life.</image>
    <lines>
      <line>Nine at the beginning means: Firm seclusion within the family. Remorse disappears. </line>
      <line>Six in the second place means: She should not follow her whims. She must attend within to the food. Perseverance brings good fortune.</line>
      <line>Nine at the third place means: When tempers flare  in the family, Too great severity brings remorse. Good fortune nonetheless. When woman and child dally and laugh, It leads in the end to humiliation.</line>
      <line>Six in the fourth place means: She is the treasure of the house. Great good fortune. </line>
      <line>Nine at the fifth place means: As a king he approaches his family. Fear not. Good fortune.</line>
      <line>Nine at the top means: His work commands respect. In the end good fortune comes.</line>
    </lines>
  </hexagram>
  <hexagram>
    <hexnum>38</hexnum>
    <pattern>996969</pattern>
    <title>K'uei - Opposition</title>
    <above>Li     The Clinging, Flame</above>
    <below>Tui    The Joyous, Lake</below>
    <judgement>Opposition. In small matters, good fortune.</judgement>
    <image>Above, fire; below, the lake Image of Opposition. Thus amid all fellowship The superior man retains his individuality.</image>
    <lines>
      <line>Nine at the beginning means: Remorse disappears. If you lose your horse, do not run after it; It will come back of its own accord. When you see evil people, Guard yourself against mistakes. </line>
      <line>Nine at the second place means: One meets his lord in a narrow street. No blame.</line>
      <line>Six in the third place means: One sees the wagon dragged back, The oxen halted, A man's hair and nose cut off. Not a good beginning, but a good end.</line>
      <line>Nine at the fourth place means: Isolated through opposition, One meets a like-minded man With whom one can associate in good faith. Despite the danger, no blame. </line>
      <line>Six in the fifth place means: Remorse disappears. The companion bites his way through the wrappings. If one goes to him, How could it be a mistake?</line>
      <line>Nine at the top means: Isolated through opposition, One sees one's companion as a pig covered with dirt, As a wagon full of devils. First one draws a bow against him, Then one lays the bow aside. He is not a robber; he will woo at the right time. As one goes, rain falls; then good fortune comes.</line>
    </lines>
  </hexagram>
  <hexagram>
    <hexnum>39</hexnum>
    <pattern>669696</pattern>
    <title>Chien - Obstruction</title>
    <above>K'an   The Abysmal, Water</above>
    <below>Kn    Keeping Still, Mountain</below>
    <judgement>Obstruction. The southwest furthers. The northeast does not further. It furthers one to see the great man. Perseverance brings good fortune.</judgement>
    <image>Water on the mountain Image of Obstruction. Thus the superior man turns his attention to himself And molds his character.</image>
    <lines>
      <line>Six at the beginning means: Going leads to obstructions, Coming meets with praise.</line>
      <line>Six in the second place means: The king's servant is beset by obstruction upon obstruction, But it is not his own fault.</line>
      <line>Nine at the third place means: Going leads to obstructions; Hence he comes back.</line>
      <line>Six in the fourth place means: Going leads to obstructions, Coming leads to union. </line>
      <line>Nine at the fifth place means: In the midst of the greatest obstructions, Friends come.</line>
      <line>Six at the top means: Going leads to obstructions, Coming leads to great good fortune. It furthers one to see the great man.</line>
    </lines>
  </hexagram>
  <hexagram>
    <hexnum>40</hexnum>
    <pattern>696966</pattern>
    <title>Hsieh - Deliverance</title>
    <above>Chn   The Arousing, Thunder</above>
    <below>K'an   The Abysmal, Water</below>
    <judgement>Deliverance. The southwest furthers. If there is no longer anything where one has to go, Return brings good fortune. If there is still something where one has to go, Hastening brings good fortune.</judgement>
    <image>Thunder and rain set in Image of Deliverance. Thus the superior man pardons mistakes And forgives misdeeds.</image>
    <lines>
      <line>Six at the beginning means: Without blame. </line>
      <line>Nine at the second place means: One kills three foxes in the field And receives a yellow arrow. Perseverance brings good fortune.</line>
      <line>Six in the third place means: If a man carries a burden on his back And nonetheless rides in a carriage, He thereby encourages robbers to draw near. Perseverance leads to humiliation.</line>
      <line>Nine at the fourth place means: Deliver yourself from your great toe. Then the companion comes, And him you can trust. </line>
      <line>Six in the fifth place means: If only the superior man can deliver himself, It brings good fortune. Thus he proves to inferior men that he is in earnest.</line>
      <line>Six at the top means: The prince shoots at a hawk on a high wall. He kills it. Everything serves to further.</line>
    </lines>
  </hexagram>
  <hexagram>
    <hexnum>41</hexnum>
    <pattern>996669</pattern>
    <title>Sun - Decrease</title>
    <above>Kn    Keeping Still, Mountain</above>
    <below>Tui    The Joyous, Lake</below>
    <judgement>Decrease combined with sincerity Brings about supreme good fortune Without blame. One may be persevering in this. It furthers one to undertake something. How is this to be carried out? One may use two small bowls for the sacrifice.</judgement>
    <image>At the foot of the mountain, the lake Image of Decrease. Thus the superior man controls his anger And restrains his instincts.</image>
    <lines>
      <line>Nine at the beginning means: Going quickly when one's tasks are finished Is without blame. But one must reflect on how much one may decrease others.</line>
      <line>Nine at the second place means: Perseverance furthers. To undertake something brings misfortune. Without decreasing oneself, One is able to bring increase to others. </line>
      <line>Six in the third place means: When three people journey together, Their number decreases by one. When one man journeys alone, He finds a companion.</line>
      <line>Six in the fourth place means: If a man decreases his faults, It makes the other hasten to come and rejoice. No blame. </line>
      <line>Six in the fifth place means: Someone does indeed increase him. Ten pairs of tortoises cannot oppose it. Supreme good fortune. </line>
      <line>Nine at the top means: If one is increased without depriving others, There is no blame. Perseverance brings good fortune. It furthers one to undertake something. One obtains servants But no longer has a separate home.</line>
    </lines>
  </hexagram>
  <hexagram>
    <hexnum>42</hexnum>
    <pattern>966699</pattern>
    <title>I - Increase</title>
    <above>Sun    The Gentle, Wind</above>
    <below>Chn   The Arousing, Thunder</below>
    <judgement>Increase. It furthers one To undertake something. It furthers one to cross the great water.</judgement>
    <image>Wind and thunder Image of Increase. Thus the superior man: If he sees good, he imitates it; If he has faults, he rids himself of them.</image>
    <lines>
      
      <line>Nine at the beginning means: It furthers one to accomplish great deeds. Supreme good fortune. No blame. </line>
      <line>Six in the second place means: Someone does indeed increase him; Ten pairs of tortoises cannot oppose it. Constant perseverance brings good fortune. The king presents him before God. Good fortune.</line>
      <line>Six in the third place means: One is enriched through unfortunate events. No blame, if you are sincere And walk in the middle, And report with a seal to the prince. </line>
      <line>Six in the fourth place means: If you walk in the middle And report to the prince, He will follow. It furthers one to be used In the removal of the capital. </line>
      <line>Nine at the fifth place means: If in truth you have a kind heart, ask not. Supreme good fortune. Truly, kindness will be recognized as your virtue.</line>
      <line>Nine at the top means: He brings increase to no one. Indeed, someone even strikes him. He does not keep his heart constantly steady. Misfortune.</line>
    </lines>
  </hexagram>
  <hexagram>
    <hexnum>43</hexnum>
    <pattern>999996</pattern>
    <title>Kuai - Break-through (Resoluteness)</title>
    <above>Tui    The Joyous, Lake</above>
    <below>Ch'ien The Creative, Heaven</below>
    <judgement>Break-through. One must resolutely make the matter known At the court of the king. It must be announced truthfully. Danger. It is necessary to notify one's own city. It does not further to resort to arms. It furthers one to undertake something.</judgement>
    <image>The lake has risen to heaven Image of Break-through. Thus the superior man Dispenses riches downward And refrains from resting on his virtue.</image>
    <lines>
      <line>Nine at the beginning means: Mighty in the forward-striding toes. When one goes and is not equal to the task, One makes a mistake.</line>
      <line>Nine at the second place means: A cry of alarm. Arms at evening and at night. Fear nothing.</line>
      <line>Nine at the third place means: To be powerful in the cheekbones Brings misfortune. The superior man is firmly resolved. He walks alone and is caught in the rain. He is bespattered, And people murmur against him. No blame.</line>
      <line>Nine at the fourth place means: There is no skin on his thighs, And walking comes hard. If a man were to let himself be led like a sheep, Remorse would disappear. But if these words are heard They will not be believed. </line>
      <line>Nine at the fifth place means: In dealing with weeds, Firm resolution is necessary. Walking in the middle Remains free of blame. </line>
      <line>Six at the top means: No cry. In the end misfortune comes.</line>
    </lines>
  </hexagram>
  <hexagram>
    <hexnum>44</hexnum>
    <pattern>699999</pattern>
    <title>Kou - Coming to Meet</title>
    <above>Ch'ien The Creative, Heaven</above>
    <below>Sun    The Gentle, Wind</below>
    <judgement>Coming to Meet. The maiden is powerful. One should not marry such a maiden.</judgement>
    <image>Under heaven, wind Image of Coming to Meet. Thus does the prince act when disseminating his commands And proclaiming them to the four quarters of heaven.</image>
    <lines>
      
      <line>Six at the beginning means: It must be checked with a brake of bronze. Perseverance brings good fortune. If one lets it take its course, one experiences misfortune. Even a lean pig has it in him to rage around. </line>
      <line>Nine at the second place means: There is a fish in the tank. No blame. Does not further guests.</line>
      <line>Nine at the third place means: There is no skin on his thighs, And walking comes hard. If one is mindful of the danger, No great mistake is made.</line>
      <line>Nine at the fourth place means: No fish in the tank. This leads to misfortune. </line>
      <line>Nine at the fifth place means: A melon covered with willow leaves. Hidden lines. Then it drops down to one from heaven.</line>
      <line>Nine at the top means: He comes to meet with his horns. Humiliation. No blame.</line>
    </lines>
  </hexagram>
  <hexagram>
    <hexnum>45</hexnum>
    <pattern>666996</pattern>
    <title>Ts'ui - Gathering Together [Massing]</title>
    <above>Tui    The Joyous, Lake</above>
    <below>K'un   The Receptive, Earth</below>
    <judgement>Gathering Together. Success. The king approaches his temple. It furthers one to see the great man. This brings success. Perseverance furthers. To bring great offerings creates good fortune. It furthers one to undertake something.</judgement>
    <image>Over the earth, the lake Image of Gathering Together. Thus the superior man renews his weapons In order to meet the unforseen.</image>
    <lines>
      <line>Six at the beginning means: If you are sincere, but not to the end, There will sometimes be confusion, sometimes gathering together. If you call out, Then after one grasp of the hand you can laugh again. Regret not. Going is without blame.</line>
      <line>Six in the second place means: Letting oneself be drawn Brings good fortune and remains blameless. If one is sincere, It furthers one to bring even a small offering.</line>
      <line>Six in the third place means: Gathering together amid sighs. Nothing that would further. Going is without blame. Slight humiliation. </line>
      <line>Nine at the fourth place means: Great good fortune. No blame. </line>
      <line>Nine at the fifth place means: If in gathering together one has position, This brings no blame. If there are some who are not yet sincerely in the work, Sublime and enduring perseverance is needed. Then remorse disappears.</line>
      <line>Six at the top means: Lamenting and sighing, floods of tears. No blame.</line>
    </lines>
  </hexagram>
  <hexagram>
    <hexnum>46</hexnum>
    <pattern>699666</pattern>
    <title>Shng - Pushing Upward</title>
    <above>K'un   The Receptive, Earth</above>
    <below>Sun    The Gentle, Wind</below>
    <judgement>Pushing Upward has supreme success. One must see the great man. Fear not. Departure toward the south Brings good fortune.</judgement>
    <image>Within the earth, wood grows Image of Pushing Upward. Thus the superior man of devoted character Heaps small things In order to achieve something high and great.</image>
    <lines>
      
      <line>Six at the beginning means: Pushing upward that meets with confidence Brings great good fortune.</line>
      <line>Nine at the second place means: If one is sincere, It furthers one to bring even a small offering. No blame.</line>
      <line>Nine at the third place means: One pushes upward into an empty city.</line>
      <line>Six in the fourth place means: The king offers him Mount Ch'i. Good fortune. No blame. </line>
      <line>Six in the fifth place means: Perseverance brings good fortune. One pushes upward by steps.</line>
      <line>Six at the top means: Pushing upward in darkness. It furthers one To be unremittingly persevering.</line>
    </lines>
  </hexagram>
  <hexagram>
    <hexnum>47</hexnum>
    <pattern>696996</pattern>
    <title>K'un - Oppression (Exhaustion)</title>
    <above>Tui    The Joyous, Lake</above>
    <below>K'an   The Abysmal, Water</below>
    <judgement>Oppression. Success. Perseverance. The great man brings about good fortune. No blame. When one has something to say, It is not believed.</judgement>
    <image>There is no water in the lake Image of Exhaustion. Thus the superior man stakes his life On following his will.</image>
    <lines>
      <line>Six at the beginning means: One sits oppressed under a bare tree And strays into a gloomy valley. For three years one sees nothing. </line>
      <line>Nine at the second place means: One is oppressed while at meat and drink. The man with the scarlet knee bands is just coming. It furthers one to offer sacrifice. To set forth brings misfortune. No blame.</line>
      <line>Six in the third place means: A man permits himself to be oppressed by stone, And leans on thorns and thistles. He enters his house and does not see his wife. Misfortune.</line>
      <line>Nine at the fourth place means: He comes very quietly, oppressed in a golden carriage. Humiliation, but the end is reached. </line>
      <line>Nine at the fifth place means: His nose and feet are cut off. Oppression at the hands of the man with the purple knee bands. Joy comes softly. It furthers one to make offerings and libations.</line>
      <line>Six at the top means: He is oppressed by creeping vines. He moves uncertainly and says, "Movement brings remorse." If one feels remorse over this and makes a start, Good fortune comes.</line>
    </lines>
  </hexagram>
  <hexagram>
    <hexnum>48</hexnum>
    <pattern>699696</pattern>
    <title>Ching - The Well</title>
    <above>K'an   The Abysmal, Water</above>
    <below>Sun    The Gentle, Wind</below>
    <judgement>The Well. The town may be changed, But the well cannot be changed. It neither decreases nor increases. They come and go and draw from the well. If one gets down almost to the water And the rope does not go all the way, Or the jug breaks, it brings misfortune.</judgement>
    <image>Water over wood Image of the Well. Thus the superior man encourages the people at their work, And exhorts them to help one another.</image>
    <lines>
      <line>Six at the beginning means: One does not drink the mud of the well. No animals come to an old well.</line>
      <line>Nine at the second place means: At the wellhole one shoots fishes. The jug is broken and leaks.</line>
      <line>Nine at the third place means: The well is cleaned, but no one drinks from it. This is my heart's sorrow, For one might draw from it. If the king were clear-minded, Good fortune might be enjoyed in common.</line>
      <line>Six in the fourth place means: The well is being lined. No blame. </line>
      <line>Nine at the fifth place means: In the well there is a clear, cold spring From which one can drink.</line>
      <line>Six at the top means: One draws from the well Without hindrance. It is dependable. Supreme good fortune.</line>
    </lines>
  </hexagram>
  <hexagram>
    <hexnum>49</hexnum>
    <pattern>969996</pattern>
    <title>Ko - Revolution (Molting)</title>
    <above>Tui    The Joyous, Lake</above>
    <below>Li     The Clinging, Flame</below>
    <judgement>Revolution. On your own day You are believed. Supreme success, Furthering through perseverance. Remorse disappears.</judgement>
    <image>Fire in the lake Image of Revolution. Thus the superior man Sets the calendar in order And makes the seasons clear.</image>
    <lines>
      <line>Nine at the beginning means: Wrapped in the hide of a yellow cow.</line>
      <line>Six in the second place means: When one's own day comes, one may create revolution. Starting brings good fortune. No blame.</line>
      <line>Nine at the third place means: Starting brings misfortune. Perseverance brings danger. When talk of revolution has gone the rounds three times, One may commit himself, And men will believe him.</line>
      <line>Nine at the fourth place means: Remorse disappears. Men believe him. Changing the form of government brings good fortune. </line>
      <line>Nine at the fifth place means: The great man changes like a tiger. Even before he questions the oracle He is believed.</line>
      <line>Six at the top means: The superior man changes like a panther. The inferior man molts in the face. Starting brings misfortune. To remain persevering brings good fortune.</line>
    </lines>
  </hexagram>
  <hexagram>
    <hexnum>50</hexnum>
    <pattern>699969</pattern>
    <title>Ting - The Caldron</title>
    <above>Li     The Clinging, Flame</above>
    <below>Sun    The Gentle, Wind</below>
    <judgement>The Caldron. Supreme good fortune. Success.</judgement>
    <image>Fire over wood Image of the Caldron. Thus the superior man consolidates his fate By making his position correct.</image>
    <lines>
      <line>Six at the beginning means: A ting with legs upturned. Furthers removal of stagnating stuff. One takes a concubine for the sake of her son. No blame.</line>
      <line>Nine at the second place means: There is food in the ting. My comrades are envious, But they cannot harm me. Good fortune.</line>
      <line>Nine at the third place means: The handle of the ting is altered. One is impeded in his way of life. The fat of the pheasant is not eaten. Once rain falls, remorse is spent. Good fortune comes in the end.</line>
      <line>Nine at the fourth place means: The legs of the ting are broken. The prince's meal is spilled And his person is soiled. Misfortune. </line>
      <line>Six in the fifth place means: The ting has yellow handles, golden carrying rings. Perseverance furthers. </line>
      <line>Nine at the top means: The ting has rings of jade. Great good fortune. Nothing that would not act to further.</line>
    </lines>
  </hexagram>
  <hexagram>
    <hexnum>51</hexnum>
    <pattern>966966</pattern>
    <title>Chn - The Arousing (Shock, Thunder)</title>
    <above>Chn   The Arousing, Thunder</above>
    <below>Chn   The Arousing, Thunder</below>
    <judgement>Shock brings success. Shock comes-oh, oh! Laughing words-ha, ha! The shock terrifies for a hundred miles, And he does not let fall the sacrificial spoon and chalice.</judgement>
    <image>Thunder repeated Image of Shock. Thus in fear and trembling The superior man sets his life in order And examines himself.</image>
    <lines>
      
      <line>Nine at the beginning means: Shock comes-oh, oh! Then follow laughing words-ha, ha! Good fortune.</line>
      <line>Six in the second place means: Shock comes bringing danger. A hundred thousand times You lose your treasures And must climb the nine hills. Do not go in pursuit of them. After seven days you will get them back.</line>
      <line>Six in the third place means: Shock comes and makes one distraught. If shock spurs to action One remains free of misfortune.</line>
      <line>Nine at the fourth place means: Shock is mired.</line>
      <line>Six in the fifth place means: Shock goes hither and thither. Danger. However, nothing at all is lost. Yet there are things to be done.</line>
      <line>Six at the top means: Shock brings ruin and terrified gazing around. Going ahead brings misfortune. If it has not yet touched one's own body But has reached one's neighbor first, There is no blame. One's comrades have something to talk about.</line>
    </lines>
  </hexagram>
  <hexagram>
    <hexnum>52</hexnum>
    <pattern>669669</pattern>
    <title>Kn - Keeping Still, Mountain</title>
    <above>Kn    Keeping Still, Mountain</above>
    <below>Kn    Keeping Still, Mountain</below>
    <judgement>Keeping Still. Keeping his back still So that he no longer feels his body. He goes into his courtyard And does not see his people. No blame.</judgement>
    <image>Mountains standing close together Image of Keeping Still. Thus the superior man Does not permit his thoughts To go beyond his situation.</image>
    <lines>
      <line>Six at the beginning means: Keeping his toes still. No blame. Continued perseverance furthers.</line>
      <line>Six in the second place means: Keeping his calves still. He cannot rescue him whom he follows. His heart is not glad.</line>
      <line>Nine at the third place means: Keeping his hips still. Making his sacrum stiff. Dangerous. The heart suffocates.</line>
      <line>Six in the fourth place means: Keeping his trunk still. No blame.</line>
      <line>Six in the fifth place means: Keeping his jaws still. The words have order. Remorse disappears. </line>
      <line>Nine at the top means: Noblehearted keeping still. Good fortune.</line>
    </lines>
  </hexagram>
  <hexagram>
    <hexnum>53</hexnum>
    <pattern>669699</pattern>
    <title>Chien - Development (Gradual Progress)</title>
    <above>Sun    The Gentle, Wind</above>
    <below>Kn    Keeping Still, Mountain</below>
    <judgement>Development. The maiden Is given in marriage. Good fortune. Perseverance furthers.</judgement>
    <image>On the mountain, a tree Image of Development. Thus the superior man abides in dignity and virtue, In order to improve the mores.</image>
    <lines>
      <line>Six at the beginning means: The wild goose gradually draws near the shore. The young son is in danger. There is talk. No blame. </line>
      <line>Six in the second place means: The wild goose gradually draws near the cliff. Eating and drinking in peace and concord. Good fortune.</line>
      <line>Nine at the third place means: The wild goose gradually draws near the plateau. The man goes forth and does not return. The woman carries a child but does not bring it forth. Misfortune. It furthers one to fight off robbers.</line>
      <line>Six in the fourth place means: The wild goose gradually draws near the tree. Perhaps it will find a flat branch. No blame. </line>
      <line>Nine at the fifth place means: The wild goose gradually draws near the summit. For three years the woman has no child. In the end nothing can hinder her. Good fortune.</line>
      <line>Nine at the top means: The wild goose gradually draws near the cloud heights. Its feathers can be used for the sacred dance. Good fortune.</line>
    </lines>
  </hexagram>
  <hexagram>
    <hexnum>54</hexnum>
    <pattern>996966</pattern>
    <title>Kuei Mei - The Marrying Maiden</title>
    <above>Chn   The Arousing, Thunder</above>
    <below>Tui    The Joyous, Lake</below>
    <judgement>The Marrying Maiden. Undertakings bring misfortune. Nothing that would further.</judgement>
    <image>Thunder over the lake Image of the Marrying Maiden. Thus the superior man Understands the transitory In the light of the eternity of the end.</image>
    <lines>
      <line>Nine at the beginning means: The marrying maiden as a concubine. A lame man who is able to tread. Undertakings bring good fortune.</line>
      <line>Nine at the second place means: A one-eyed man who is able to see. The perseverance of a solitary man furthers. </line>
      <line>Six in the third place means: The marrying maiden as a slave. She marries as a concubine.</line>
      <line>Nine at the fourth place means: The marrying maiden draws out the allotted time. A late marriage comes in due course. </line>
      <line>Six in the fifth place means: The sovereign I gave his daughter in marriage. The embroidered garments of the princess Were not as gorgeous As those of the servingmaid. The moon that is nearly full Brings good fortune. </line>
      <line>Six at the top means: The woman holds the basket, but there are no fruits in it. The man stabs the sheep, but no blood flows. Nothing that acts to further.</line>
    </lines>
  </hexagram>
  <hexagram>
    <hexnum>55</hexnum>
    <pattern>969966</pattern>
    <title>Fng - Abundance [Fullness]</title>
    <above>Chn   The Arousing, Thunder</above>
    <below>Li     The Clinging, Flame</below>
    <judgement>Abundance has success. The king attains abundance. Be not sad. Be like the sun at midday.</judgement>
    <image>Both thunder and lightning come Image of Abundance. Thus the superior man decides lawsuits And carries out punishments.</image>
    <lines>
      <line>Nine at the beginning means: When a man meets his destined ruler, They can be together ten days, And it is not a mistake. Going meets with recognition.</line>
      <line>Six in the second place means: The curtain is of such fullness That the polestars can be seen at noon. Through going one meets with mistrust and hate. If one rouses him through truth, Good fortune comes.</line>
      <line>Nine at the third place means: The underbrush is of such abundance That the small stars can be seen at noon. He breaks his right arm. No blame.</line>
      <line>Nine at the fourth place means: The curtain is of such fullness That the polestars can be seen at noon. He meets his ruler, who is of like kind. Good fortune. </line>
      <line>Six in the fifth place means: lines are coming, Blessing and fame draw near. Good fortune.</line>
      <line>Six at the top means: His house is in a state of abundance. He screens off his family. He peers through the gate And no longer perceives anyone. For three years he sees nothing. Misfortune.</line>
    </lines>
  </hexagram>
  <hexagram>
    <hexnum>56</hexnum>
    <pattern>669969</pattern>
    <title>Lu - The Wanderer</title>
    <above>Li     The Clinging, Flame</above>
    <below>Kn    Keeping Still, Mountain</below>
    <judgement>The Wanderer. Success through smallness. Perseverance brings good fortune To the wanderer.</judgement>
    <image>Fire on the mountain Image of the Wanderer. Thus the superior man Is clear-minded and cautious In imposing penalties, And protracts no lawsuits.</image>
    <lines>
      <line>Six at the beginning means: If the wanderer busies himself with trivial things, He draws down misfortune upon himself.</line>
      <line>Six in the second place means: The wanderer comes to an inn. He has his property with him. He wins the steadfastness of a young servant.</line>
      <line>Nine at the third place means: The wanderer's inn burns down. He loses the steadfastness of his young servant. Danger.</line>
      <line>Nine at the fourth place means: The wanderer rests in a shelter. He obtains his property and an ax. My heart is not glad. </line>
      <line>Six in the fifth place means: He shoots a pheasant. It drops with the first arrow. In the end this brings both praise and office.</line>
      <line>Nine at the top means: The bird's nest burns up. The wanderer laughs at first, Then must needs lament and weep. Through carelessness he loses his cow. Misfortune.</line>
    </lines>
  </hexagram>
  <hexagram>
    <hexnum>57</hexnum>
    <pattern>699699</pattern>
    <title>Sun - The Gentle (The Penetrating, Wind)</title>
    <above>Sun    The Gentle, Wind</above>
    <below>Sun    The Gentle, Wind</below>
    <judgement>The Gentle. Success through what is small. It furthers one to have somewhere to go. It furthers one to see the great man.</judgement>
    <image>Winds following one upon the other Image of the Gently Penetrating. Thus the superior man Spreads his commands abroad And carries out his undertakings.</image>
    <lines>
      
      <line>Six at the beginning means: In advancing and in retreating, The perseverance of a warrior furthers.</line>
      <line>Nine at the second place means: Penetration under the bed. Priests and magicians are used in great number. Good fortune. No blame.</line>
      <line>Nine at the third place means: Repeated penetration. Humiliation. </line>
      <line>Six in the fourth place means: Remorse vanishes. During the hunt Three kinds of game are caught. </line>
      <line>Nine at the fifth place means: Perseverance brings good fortune. Remorse vanishes. Nothing that does not further. No beginning, but an end. Before the change, three days. After the change, three days. Good fortune.</line>
      <line>Nine at the top means: Penetration under the bed. He loses his property and his ax. Perseverance brings misfortune.</line>
    </lines>
  </hexagram>
  <hexagram>
    <hexnum>58</hexnum>
    <pattern>996996</pattern>
    <title>Tui - The Joyous, Lake</title>
    <above>Tui    The Joyous, Lake</above>
    <below>Tui    The Joyous, Lake</below>
    <judgement>The Joyous. Success. Perseverance is favorable.</judgement>
    <image>Lakes resting one on the other Image of the Joyous. Thus the superior man joins with his friends For discussion and practice.</image>
    <lines>
      <line>Nine at the beginning means: Contented joyousness. Good fortune. </line>
      <line>Nine at the second place means: Sincere joyousness. Good fortune. Remorse disappears. </line>
      <line>Six in the third place means: Coming joyousness. Misfortune.</line>
      <line>Nine at the fourth place means: Joyousness that is weighed is not at peace. After ridding himself of mistakes a man has joy. </line>
      <line>Nine at the fifth place means: Sincerity toward disintegrating influences is dangerous. </line>
      <line>Six at the top means: Seductive joyousness.</line>
    </lines>
  </hexagram>
  <hexagram>
    <hexnum>59</hexnum>
    <pattern>696699</pattern>
    <title>Huan - Dispersion [Dissolution]</title>
    <above>Sun    The Gentle, Wind</above>
    <below>K'an   The Abysmal, Water</below>
    <judgement>Dispersion. Success. The king approaches his temple. It furthers one to cross the great water. Perseverance furthers.</judgement>
    <image>The wind drives over the water Image of Dispersion. Thus the kings of old sacrificed to the Lord And built temples.</image>
    <lines>
      <line>Six at the beginning means: He brings help with the strength of a horse. Good fortune. </line>
      <line>Nine at the second place means: At the dissolution He hurries to that which supports him. Remorse disappears.</line>
      <line>Six in the third place means: He dissolves his self. No remorse. </line>
      <line>Six in the fourth place means: He dissolves his bond with his group. Supreme good fortune. Dispersion leads in turn to accumulation. This is something that ordinary men do not think of. </line>
      <line>Nine at the fifth place means: His loud cries are as dissolving as sweat. Dissolution. A king abides without blame.</line>
      <line>Nine at the top means: He dissolves his blood. Departing, keeping at a distance, going out, Is without blame.</line>
    </lines>
  </hexagram>
  <hexagram>
    <hexnum>60</hexnum>
    <pattern>996696</pattern>
    <title>Chieh - Limitation</title>
    <above>K'an   The Abysmal, Water</above>
    <below>Tui    The Joyous, Lake</below>
    <judgement>Limitation. Success. Galling limitation must not be persevered in.</judgement>
    <image>Water over lake Image of Limitation. Thus the superior man Creates number and measure, And examines the nature of virtue and correct conduct.</image>
    <lines>
      <line>Nine at the beginning means: Not going out of the door and the courtyard Is without blame.</line>
      <line>Nine at the second place means: Not going out of the gate and the courtyard Brings misfortune.</line>
      <line>Six in the third place means: He who knows no limitation Will have cause to lament. No blame.</line>
      <line>Six in the fourth place means: Contented limitation. Success. </line>
      <line>Nine at the fifth place means: Sweet limitation brings good fortune. Going brings esteem.</line>
      <line>Six at the top means: Galling limitation. Perseverance brings misfortune. Remorse disappears.</line>
    </lines>
  </hexagram>
  <hexagram>
    <hexnum>61</hexnum>
    <pattern>996699</pattern>
    <title>Chung Fu - Inner Truth</title>
    <above>Sun    The Gentle, Wind</above>
    <below>Tui    The Joyous, Lake</below>
    <judgement>Inner Truth. Pigs and fishes. Good fortune. It furthers one to cross the great water. Perseverance furthers.</judgement>
    <image>Wind over lake Image of Inner Truth. Thus the superior man discusses criminal cases In order to delay executions.</image>
    <lines>
      <line>Nine at the beginning means: Being prepared brings good fortune. If there are secret designs, it is disquieting.</line>
      <line>Nine at the second place means: A crane calling in the shade. Its young answers it. I have a good goblet. I will share it with you. </line>
      <line>Six in the third place means: He finds a comrade. Now he beats the drum, now he stops. Now he sobs, now he sings. </line>
      <line>Six in the fourth place means: The moon nearly at the full. The team horse goes astray. No blame. </line>
      <line>Nine at the fifth place means: He possesses truth, which links together. No blame.</line>
      <line>Nine at the top means: Cockcrow penetrating to heaven. Perseverance brings misfortune.</line>
    </lines>
  </hexagram>
  <hexagram>
    <hexnum>62</hexnum>
    <pattern>669966</pattern>
    <title>Hsiao Kuo - Preponderance of the Small</title>
    <above>Chn   The Arousing, Thunder</above>
    <below>Kn    Keeping Still, Mountain</below>
    <judgement>Preponderance of the Small. Success. Perseverance furthers. Small things may be done; great things should not be done. The flying bird brings the message: It is not well to strive upward, It is well to remain below. Great good fortune.</judgement>
    <image>Thunder on the mountain Image of Preponderance of the Small. Thus in his conduct the superior man gives preponderance to reverence. In bereavement he gives preponderance to grief. In his expenditures he gives preponderance to thrift.</image>
    <lines>
      <line>Six at the beginning means: The bird meets with misfortune through flying. </line>
      <line>Six in the second place means: She passes by her ancestor And meets her ancestress. He does not reach his prince And meets the official. No blame.</line>
      <line>Nine at the third place means: If one is not extremely careful, Somebody may come from behind and strike him. Misfortune.</line>
      <line>Nine at the fourth place means: No blame. He meets him without passing by. Going brings danger. One must be on guard. Do not act. Be constantly persevering. </line>
      <line>Six in the fifth place means: Dense clouds, No rain from our western territory. The prince shoots and hits him who is in the cave.</line>
      <line>Six at the top means: He passes him by, not meeting him. The flying bird leaves him. Misfortune. This means bad luck and injury.</line>
    </lines>
  </hexagram>
  <hexagram>
    <hexnum>63</hexnum>
    <pattern>969696</pattern>
    <title>Chi Chi - After Completion</title>
    <above>K'an   The Abysmal, Water</above>
    <below>Li     The Clinging, Flame</below>
    <judgement>After Completion. Success in small matters. Perseverance furthers. At the beginning good fortune, At the end disorder.</judgement>
    <image>Water over fire Image of the condition In After Completion. Thus the superior man Takes thought of misfortune And arms himself against it in advance.</image>
    <lines>
      <line>Nine at the beginning means: He brakes his wheels. He gets his tail in the water. No blame. </line>
      <line>Six in the second place means: The woman loses the curtain of her carriage. Do not run after it; On the seventh day you will get it.</line>
      <line>Nine at the third place means: The Illustrious Ancestor Disciplines the Devil's Country. After three years he conquers it. Inferior people must not be employed.</line>
      <line>Six in the fourth place means: The finest clothes turn to rags. Be careful all day long.</line>
      <line>Nine at the fifth place means: The neighbor in the east who slaughters an ox Does not attain as much real happiness As the neighbor in the west With his small offering.</line>
      <line>Six at the top means: He gets his head in the water. Danger.</line>
    </lines>
  </hexagram>
  <hexagram>
    <hexnum>64</hexnum>
    <pattern>696969</pattern>
    <title>Wei Chi - Before Completion</title>
    <above>Li     The Clinging, Flame</above>
    <below>K'an   The Abysmal, Water</below>
    <judgement>Before Completion. Success. But if the little fox, after nearly completing the crossing, Gets his tail in the water, There is nothing that would further.</judgement>
    <image>Fire over water Image of the condition before transition. Thus the superior man is careful In the differentiation of things, So that each finds its place.</image>
    <lines>
      <line>Six at the beginning means: He gets his tail in the water. Humiliating.</line>
      <line>Nine at the second place means: He brakes his wheels. Perseverance brings good fortune.</line>
      <line>Six in the third place means: Before completion, attack brings misfortune. It furthers one to cross the great water.</line>
      <line>Nine at the fourth place means: Perseverance brings good fortune. Remorse disappears. Shock, thus to discipline the Devil's Country. For three years, great realms are awarded. </line>
      <line>Six in the fifth place means: Perseverance brings good fortune. No remorse. The light of the superior man is true. Good fortune.</line>
      <line>Nine at the top means: There is drinking of wine In genuine confidence. No blame. But if one wets his head, He loses it, in truth.</line>
    </lines>
  </hexagram>
</hexagrams>

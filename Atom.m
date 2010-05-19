// ReelSnail
// Copyright (C) 2010  Petteri Hietavirta
//
// This file is part of ReelSnail.
// 
// ReelSnail is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
// reelsnail@gmail.com
//

#import "Atom.h"


@implementation Atom

-(void)setSize:(long)x {
    size = x;
}
-(long)size {
    return size;
}

-(void)setOffset:(long)x {
    offset = x;
}
-(long)offset {
    return offset;
}

-(NSString*)type {
    return type;
}

-(void)setType:(NSString*)x{
    [x retain];
    [type release];
    type = x;
}

-(NSString*) description {
    return [NSString stringWithFormat:@"type: %S offset: %d size: %d", [self type], [self size],[self size]];
}

@end

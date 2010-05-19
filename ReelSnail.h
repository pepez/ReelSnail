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

#import <Cocoa/Cocoa.h>
#import <Atom.h>

@interface ReelSnail : NSObject {
    IBOutlet NSTextField *textOut; 
    IBOutlet NSButton *saveButtonOut;

    NSMutableData* movieData;
    NSMutableArray* movieAtoms;  
    long currentRate;
    
}
- (Atom*)readAtomFromData:(NSData*)data offset:(long)offset;
- (IBAction)selectFiles:(id)sender;
- (IBAction)saveFiles:(id)sender;
@end

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

#import "ReelSnail.h"
#import "Atom.h"

@implementation ReelSnail



-(Atom*)readAtomFromData:(NSData*)data offset:(long)offset{
    NSRange range = {offset, 4};
    unsigned char aBuffer[4];
    [data getBytes:aBuffer range:range];
    
    long x = *(long *)aBuffer; 
    long size = CFSwapInt32BigToHost(x);

    NSLog(@"offset: %d \n", offset);
    NSLog(@"size big endian: %d \n", size);
    
    range = NSMakeRange(offset+4,4);
    [data getBytes:aBuffer range:range];
    NSString* type = [[NSString alloc] initWithBytes:aBuffer length:sizeof(aBuffer) encoding:NSASCIIStringEncoding];
    NSLog(@"type: %@ \n",  type);
   
    Atom* atom = [[Atom alloc] init];
    [atom setType:type];
    [atom setSize:size];
    [atom setOffset:offset];
    return atom;
}

-(void)searchDurationAtoms:(NSData*)data offset:(long)offset moovStop:(long)moovStop moovAtoms:(NSMutableArray*) moovAtoms{
    do {
        
        Atom* atom = [self readAtomFromData:data offset:offset];

        if (
            [[atom type] isEqualToString:@"trak"] || 
            [[atom type] isEqualToString:@"mdia"]) {
            // recurse in chlid atom
            [self searchDurationAtoms:data offset:offset+8 moovStop:offset+[atom size] moovAtoms:moovAtoms];

        } else if ([[atom type] isEqualToString:@"mvhd"] || [[atom type] isEqualToString:@"mdhd"] ) {
            [moovAtoms addObject:atom];
        }

        // Next child atom
        offset = offset+[atom size];
        
    } while (offset<moovStop); 
}

- (IBAction)selectFiles:(id)sender {
    
    // Create the File Open Dialog class.
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    NSArray* types = [NSArray arrayWithObjects:@"mov", @"MOV", nil];
    // Enable the selection of files in the dialog.
    [openDlg setCanChooseFiles:YES];
    [openDlg setAllowedFileTypes:types];
    [openDlg setCanChooseDirectories:NO];
    
    // Display the dialog.  If the OK button was pressed,
    // process the files.
    if ( [openDlg runModalForDirectory:nil file:nil] == NSOKButton )
    {
        // Get an array containing the full filenames of all
        // files and directories selected.
        NSArray* files = [openDlg filenames];
        
        // Loop through all the files and process them.
        for(int i = 0; i < [files count]; i++ )
        {
            NSString* fileName = [files objectAtIndex:i];

            movieData = [[NSMutableData dataWithContentsOfFile:fileName] retain];
            
            NSMutableArray* topLevelAtoms = [[NSMutableArray alloc] init];
            movieAtoms = [[NSMutableArray alloc] init];
            
            long offset = 0;
            
            long moovPos, moovSize;
            
            do {
                Atom* atom = [self readAtomFromData:movieData offset:offset];   
                offset = offset + [atom size];
                [topLevelAtoms addObject:atom];
                if ([[atom type] isEqualToString:@"moov" ]) {
                    moovPos = [atom offset];
                    moovSize = [atom size];
                }
            } while (offset<[movieData length]);
            
            // FIXME do some sanity checks!
            
            
            // Read atoms inside moov atom
            [self searchDurationAtoms:movieData offset:moovPos+8 moovStop:moovPos+moovSize moovAtoms:movieAtoms]; 
            
           // long currentRate;
            
            NSEnumerator *enumerator = [movieAtoms objectEnumerator];
            id anAtom;
            while (anAtom = [enumerator nextObject]) {
                NSLog(@"moov atom type: %@ \n",  [anAtom type]);
                
                NSRange range = {[anAtom offset] +20, 4};
                unsigned char aBuffer[4];
                [movieData getBytes:aBuffer range:range];
                
                long x = *(long *)aBuffer; 
                long value = CFSwapInt32BigToHost(x);
                NSLog(@"time scale: %d \n", value);
                
                if ([[anAtom type]isEqualToString:@"mvhd" ]) {
                    currentRate = value;
                }
                
            }

            [textOut setEnabled:YES];
            [textOut setIntValue:currentRate];
            [saveButtonOut setEnabled:YES];


        }
    }
}
    
- (IBAction)saveFiles:(id)sender {

    long newRate = [textOut intValue];

    // Create the File Open Dialog class.
    NSSavePanel* saveDlg = [NSSavePanel savePanel];
    NSArray* types = [NSArray arrayWithObjects:@"mov", @"MOV", nil];
    [saveDlg setAllowedFileTypes:types];
    if ( [saveDlg runModalForDirectory:nil file:nil] == NSOKButton ){

    
     NSEnumerator *enumerator = [movieAtoms objectEnumerator];
    id anAtom;
    while (anAtom = [enumerator nextObject]) {
        NSLog(@"Editing atom type: %@ \n",  [anAtom type]);
        NSRange range = {[anAtom offset] +20, 4};
        unsigned char aBuffer[4];
        [movieData getBytes:aBuffer range:range];
        
        long x = *(long *)aBuffer; 
        long originalRate = CFSwapInt32BigToHost(x);
        
        
        if (originalRate == currentRate) {
            long newBigEndianRate = CFSwapInt32HostToBig(newRate);
            char* pBlah = (char*)&newBigEndianRate;
            [movieData replaceBytesInRange:range withBytes:pBlah];
        } 
        
    }
    
   [movieData writeToFile:[saveDlg filename] atomically:NO];
    }
}

- (BOOL)validateMenuItem:(NSMenuItem *)item {
    if ([item action] == @selector(selectFiles:)) {
        return YES;
    }
    return [saveButtonOut isEnabled];
}
@end

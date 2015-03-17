//#!/usr/bin/env bsh

import java.io.DataInputStream;
import java.io.EOFException;
import java.io.IOException;

class FloatReader {
	public static void main(String[] args) throws IOException {
		DataInputStream dis = new DataInputStream(System.in);
		float f;
		try {
			while( true ) {
				f = dis.readFloat();
				System.out.println("" + f);
			}
		} catch( EOFException e ) {
		}
	}
}

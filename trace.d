#!/usr/bin/env rdmd

import std.random;
import std.math;

import std.bitmanip : nativeToBigEndian;
import core.sys.posix.unistd : write;

struct Vector3D {
    real x;
    real y;
    real z;
};

struct OffDir {
    Vector3D offset;
    Vector3D direction;
};

struct Volume {
    real minX, minY, minZ, maxX, maxY, maxZ;
};

struct IntersectionResult {
    // TODO: before, at, past points
};

IntersectionResult findIntersection( Volume vol, OffDir pos ) {
    // TODO:
    // Scale = infinity
    // For each X, Y, Z:
    //   Too long?  Shrink scale to match distance to border in $direction
    return IntersectionResult();
};

/**
 * Transforms a screen position to a vector
 */
interface Projection {
    /**
     * ax, ay = fovX, fovY * screen position (-0.5 to 0.5)
     */
    Vector3D project( real ax, real ay );
};

class FisheyeProjection : Projection {
    Vector3D project( real ax, real ay ) {
        real avSquared = ay * ay + ax * ax;
        real angleFromCenter = sqrt(avSquared);
        real dz = -cos(angleFromCenter);
        real dv = sin(angleFromCenter);
        real dy, dx;
        if( angleFromCenter == 0 ) {
            dx = dy = 0;
        } else {
            dx = dv * (ax / angleFromCenter);
            dy = dv * (ay / angleFromCenter);
        }
        assert( dx != 0 || dy != 0 || dz != 0 );
        return Vector3D( dx, dy, dz );
    }
}

/**
 * Transforms a vector to a offset+direction
 */
interface Aperture {
    OffDir waggle( Vector3D projected );
}

class NormalAperture : Aperture {
    const real focalDistance;
    
    this( real focalDistance ) {
        this.focalDistance = focalDistance;
    }
    
    OffDir waggle( Vector3D projected ) {
        // TODO actually implement
        return OffDir(
            Vector3D(0,0,0),
            projected
        );
    }
}

struct Lens {
    real fovX, fovY;
    Projection projection;
    Aperture aperature;
};

void writeFloat( float v ) {
  ubyte[float.sizeof] x_fixed = nativeToBigEndian(v);
  write( 1, x_fixed.ptr, x_fixed.length );
}

struct LightRay {
    OffDir going;
    /** For purposes of refraction */
    real frequency;
}

struct Color {
    real red;
    real green;
    real blue;
}

struct Sample {
    real psX, psY;
    LightRay ray;
    real weight;
    Color radiance;
}

void writeVector( Vector3D v ) {
    writeFloat(v.x);
    writeFloat(v.y);
    writeFloat(v.z);
}

void writeColor( Color c ) {
    writeFloat(c.red);
    writeFloat(c.green);
    writeFloat(c.blue);
}

void writeSample( Sample s ) {
    writeFloat( s.psX );
    writeFloat( s.psY );
    writeVector( s.ray.going.offset );
    writeVector( s.ray.going.direction );
    writeFloat( s.ray.frequency );
    writeFloat( s.weight );
    writeColor( s.radiance );
}

Sample trace( real psX, real psY, OffDir from ) {
    return Sample(
        psX, psY,
        LightRay(
            from,
            600_000_000_000_000 // 600THz; somewhere in the middle of the visible spectrum
        ),
        1,
        Color( psX, psY, 0 )
    );
}

/**
 * Width of margin around sampled areas of pixel
 * so that x,y coordinates get rounded correctly
 */
const real PIXSUBSAMPBORDER = 0.0001;

void main() {
    Lens l = Lens( 120, 90, new FisheyeProjection(), new NormalAperture(0) );
    MinstdRand gen;
    int w = 240;
    int h = 160;
    for( int y=0; y<h; ++y ) {
        for( int x=0; x<w; ++x ) {
            real sx = x + uniform(PIXSUBSAMPBORDER,1-PIXSUBSAMPBORDER,gen);
            real sy = y + uniform(PIXSUBSAMPBORDER,1-PIXSUBSAMPBORDER,gen);
            real psX = l.fovX * (sx - 1);
            real psY = l.fovY * (sy - 1);
            Vector3D dir = l.projection.project( psX, psY );
            OffDir op = l.aperature.waggle( dir );
            writeSample( trace( sx / w, sy / h, op ) );
        }
    }
}

package fft
{
    public class FFTElement
    {
        public var re:Number = 0.0;         // Real component
        public var im:Number = 0.0;         // Imaginary component
        public var next:FFTElement = null;  // Next element in linked list
        public var revTgt:uint;             // Target position post bit-reversal
    }
}
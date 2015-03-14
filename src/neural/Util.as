package neural 
{
	/**
	 * ...
	 * @author Ben Kuper
	 */
	public class Util 
	{
		
		public function Util() 
		{
			
		}
		
		public static function getGaussianRandom():Number
		{			
			var s:int = Math.random() * 1000;
			
			var	x : Number,		//  Repeat extracting uniform values
				y : Number,		//  in the range ( -1,1 ) until
				w : Number;		//  0 < w = x*x + y*y < 1
			do
			{
				x = ( s = ( s * 16807 ) % 2147483647 ) / 1073741823.5 - 1;
				y = ( s = ( s * 16807 ) % 2147483647 ) / 1073741823.5 - 1;
				w = x * x + y * y;
			}
			while ( w >= 1 || !w );
				
			w = Math.sqrt ( -2 * Math.log ( w ) / w );
			
			return y * w;			//  and return the other.
		}
	}

}
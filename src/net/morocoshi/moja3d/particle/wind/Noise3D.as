package net.morocoshi.moja3d.particle.wind 
{
	import flash.geom.Vector3D;
	import net.morocoshi.common.math.random.MT;
	
	/**
	 * 乱気流用のノイズ
	 * 
	 * @author tencho
	 */
	public class Noise3D 
	{
		public var seed:int;
		public var size:Vector.<Number>;
		public var segment:Vector.<int>;
		private var vector3:Array;
		
		private var min:Vector.<int> = new Vector.<int>(3, true);
		private var max:Vector.<int> = new Vector.<int>(3, true);
		private var per:Vector.<Number> = new Vector.<Number>(3, true);
		private var ab:Vector3D = new Vector3D();
		private var cd:Vector3D = new Vector3D();
		private var ef:Vector3D = new Vector3D();
		private var gh:Vector3D = new Vector3D();
		private var abcd:Vector3D = new Vector3D();
		private var efgh:Vector3D = new Vector3D();
		
		public function Noise3D() 
		{
			size = new <Number>[1,1,1];
			segment = new <int>[];
		}
		
		/**
		 * ノイズパターンの細かさ
		 * @param	x
		 * @param	y
		 * @param	z
		 */
		public function init(seed:int, x:int, y:int, z:int):void
		{
			this.seed = seed;
			
			var mt:MT = new MT();
			mt.initialize(seed);
			
			segment[0] = x;
			segment[1] = y;
			segment[2] = z;
			vector3 = [];
			
			for (var ix:int = 0; ix < x; ix++)
			{
				vector3[ix] = [];
				for (var iy:int = 0; iy < y; iy++)
				{
					vector3[ix][iy] = [];
					for (var iz:int = 0; iz < z; iz++) 
					{
						vector3[ix][iy][iz] = new Vector3D(mt.random(), mt.random(), mt.random());
					}
				}
			}
		}
		
		/**
		 * ノイズの領域を設定
		 * @param	x
		 * @param	y
		 * @param	z
		 */
		public function setSize(x:Number, y:Number, z:Number):void
		{
			for (var i:int = 0; i < 3; i++) 
			{
				size[i] = arguments[i] / segment[i];
			}
		}
		
		public function noize(x:Number, y:Number, z:Number, output:Vector3D = null):Vector3D
		{
			for (var i:int = 0; i < 3; i++) 
			{
				var number:Number = arguments[i] / size[i];
				var integer:int = number;
				var seg:int = segment[i];
				if (integer < 0) integer = (integer % seg) + seg;
				min[i] = integer % seg;
				max[i] = (integer + 1) % seg;
				per[i] = number % 1;
			}
			
			var a:Vector3D = vector3[min[0]][min[1]][min[2]];
			var b:Vector3D = vector3[max[0]][min[1]][min[2]];
			var c:Vector3D = vector3[min[0]][max[1]][min[2]];
			var d:Vector3D = vector3[max[0]][max[1]][min[2]];
			var e:Vector3D = vector3[min[0]][min[1]][max[2]];
			var f:Vector3D = vector3[max[0]][min[1]][max[2]];
			var g:Vector3D = vector3[min[0]][max[1]][max[2]];
			var h:Vector3D = vector3[max[0]][max[1]][max[2]];
			interpolate(a, b, ab, per[0]);
			interpolate(c, d, cd, per[0]);
			interpolate(e, f, ef, per[0]);
			interpolate(g, h, gh, per[0]);
			interpolate(ab, cd, abcd, per[1]);
			interpolate(ef, gh, efgh, per[1]);
			
			var result:Vector3D = output || new Vector3D();
			interpolate(abcd, efgh, result, per[2]);
			return result;
		}
		
		public function clone():Noise3D 
		{
			var result:Noise3D = new Noise3D();
			result.seed = seed;
			result.segment = segment.concat();
			result.size = size.concat();
			
			result.vector3 = [];
			
			var nx:int = vector3.length;
			var ny:int = vector3[0].length;
			var nz:int = vector3[0][0].length;
			for (var ix:int = 0; ix < nx; ix++) 
			{
				result.vector3[ix] = [];
				for (var iy:int = 0; iy < ny; iy++)
				{
					result.vector3[ix][iy] = [];
					for (var iz:int = 0; iz < nz; iz++) 
					{
						result.vector3[ix][iy][iz] = vector3[ix][iy][iz].clone();
					}
				}
			}
			return result;
		}
		
		private function interpolate(a:Vector3D, b:Vector3D, ab:Vector3D, per:Number):void 
		{
			ab.x = a.x * (1 - per) + b.x * per;
			ab.y = a.y * (1 - per) + b.y * per;
			ab.z = a.z * (1 - per) + b.z * per;
		}
		
	}

}
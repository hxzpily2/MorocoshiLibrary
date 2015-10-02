package net.morocoshi.moja3d.shaders.depth 
{
	import flash.geom.Matrix3D;
	import net.morocoshi.moja3d.agal.AGALConstant;
	import net.morocoshi.moja3d.objects.Bone;
	import net.morocoshi.moja3d.objects.Skin;
	import net.morocoshi.moja3d.resources.Geometry;
	import net.morocoshi.moja3d.resources.VertexAttribute;
	import net.morocoshi.moja3d.shaders.AlphaMode;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	import net.morocoshi.moja3d.shaders.ShaderList;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class DepthSkinShader extends MaterialShader 
	{
		
		public var boneList:Vector.<Bone>;
		private var numBones:int;
		private var skin:Skin;
		private var skinConst:AGALConstant;
		private var depthSkinShader:DepthSkinShader;
		private var geometry:Geometry;
		
		public function DepthSkinShader() 
		{
			super();
			
			requiredAttribute.push(VertexAttribute.BONEINDEX);
			requiredAttribute.push(VertexAttribute.BONEWEIGHT);
			
			boneList = new Vector.<Bone>;
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
		}
		
		public function setGeometry(geometry:Geometry):void
		{
			this.geometry = geometry;
			updateShaderCode();
		}
		
		/**
		 * 
		 * @param	bones
		 * @param	skin
		 */
		public function initializeBones(bones:Vector.<Bone>, skin:Skin):void
		{
			this.skin = skin;
			boneList.length = 0;
			numBones = bones.length;
			
			super.updateConstants();
			for (var i:int = 0; i < numBones; i++) 
			{
				var bone:Bone = bones[i];
				bone.shadowConstant = vertexCode.addConstantListFromMatrix("@boneMatrix" + i + ":", new Matrix3D(), true);
				boneList.push(bone);
			}
			//[0]スキンMatrix定数の開始インデックス
			//[1]4
			skinConst = vertexCode.addConstantsFromArray("@skinData", [0, 4, 0, 0]);
			updateShaderCode();
		}
		
		override public function afterCreateProgram(shaderList:ShaderList):void 
		{
			skinConst.x = shaderList.getVertexConstantIndex("@boneMatrix0:");
		}
		
		override public function getKey():String 
		{
			return "DepthSkinShader:" + numBones;
		}
		
		override protected function updateAlphaMode():void
		{
			super.updateAlphaMode();
			alphaMode = AlphaMode.NONE;
		}
		
		override protected function updateTexture():void 
		{
			super.updateTexture();
		}
		
		override protected function updateConstants():void 
		{
			super.updateConstants();
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			if (numBones == 0) return;
			
			vertexConstants.number = true;
			vertexCode.addCode(
				"var $temp",
				"var $index",
				"var $tempPosition",
				"$tempPosition = @0_0_0"
			);
			
			var boneIndex:String = "va" + geometry.getAttributeIndex(VertexAttribute.BONEINDEX);
			var boneWeight:String = "va" + geometry.getAttributeIndex(VertexAttribute.BONEWEIGHT);
			
			for (var i:int = 0; i < 4; i++) 
			{
				var xyzw:String = ["x", "y", "z", "w"][i];
				vertexCode.addCode(
					//使用インデックス＝ボーンインデックス*4+開始インデックス
					"$index.x = " + boneIndex + "." + xyzw + " * @skinData.y",
					"$index.x += @skinData.x",
					
					"$temp.xyz = m44($pos, vc[$index.x])",//元の座標を行列変換
					"$temp.xyz *= " + boneWeight + "." + xyzw,//ウェイトを乗算
					"$tempPosition.xyz += $temp.xyz"
				);
			}
			vertexCode.addCode(
				"$pos.xyz = $tempPosition.xyz"
			);
		}
		
		override public function clone():MaterialShader 
		{
			var shader:DepthSkinShader = new DepthSkinShader();
			shader.setGeometry(geometry);
			return shader;
		}
		
	}

}
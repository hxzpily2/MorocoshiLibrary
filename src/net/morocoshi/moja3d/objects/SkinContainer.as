package net.morocoshi.moja3d.objects 
{
	import flash.geom.Matrix3D;
	import net.morocoshi.common.data.DataUtil;
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.renderer.RenderCollector;
	
	use namespace moja3d;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class SkinContainer extends Object3D 
	{
		
		/**このスキン内にあるボーンオブジェクトのリスト*/
		public var bones:Vector.<Bone>;
		public var skins:Vector.<Skin>;
		private var invertSkin:Matrix3D;
		
		public function SkinContainer() 
		{
			super();
			
			invertSkin = new Matrix3D();
			bones = new Vector.<Bone>;
			skins = new Vector.<Skin>;
		}
		
		/**
		 * ポリゴンベースのアウトラインを設定する
		 * @param	enabled		表示するか
		 * @param	thickness	厚さ
		 * @param	color		色
		 * @param	alpha		不透明度
		 */
		public function setOutline(enabled:Boolean, thickness:Number = 1, color:uint = 0x000000, alpha:Number = 1):void
		{
			for each(var skin:Skin in skins)
			{
				skin.setOutline(enabled, thickness, color, alpha);
			}
		}
		/**
		 * ポリゴンベースのアウトラインを表示するか
		 */
		public function set outlineEnabled(value:Boolean):void
		{
			for each(var skin:Skin in skins)
			{
				skin.outlineEnabled = value;
			}
		}
		public function get outlineEnabled():Boolean
		{
			return (skins.length == 0)? 1 : skins[0].outlineEnabled;
		}
		
		/**
		 * ポリゴンベースのアウトラインの厚さ
		 */
		public function set outlineThickness(value:Number):void
		{
			for each(var skin:Skin in skins)
			{
				skin.outlineThickness = value;
			}
		}
		public function get outlineThickness():Number
		{
			return (skins.length == 0)? 1 : skins[0].outlineThickness;
		}
		
		/**
		 * ポリゴンベースのアウトラインの色
		 */
		public function set outlineColor(value:uint):void
		{
			for each(var skin:Skin in skins)
			{
				skin.outlineColor = value;
			}
		}
		public function get outlineColor():uint
		{
			return (skins.length == 0)? 0x000000 : skins[0].outlineColor;
		}
		
		/**
		 * ポリゴンベースのアウトラインの不透明度
		 */
		public function set outlineAlpha(value:Number):void
		{
			for each(var skin:Skin in skins)
			{
				skin.outlineAlpha = value;
			}
		}
		public function get outlineAlpha():Number
		{
			return (skins.length == 0)? 1 : skins[0].outlineAlpha;
		}
		
		/**
		 * スキンメッシュの現在の姿勢で境界ボックスを更新する。ボーンの初期姿勢からのずれで計算するため実際のメッシュより大きく設定される傾向にあります。
		 */
		public function updateSkinBounds(bones:Vector.<Bone>):void
		{
			var skin:Skin;
			for each (skin in skins) 
			{
				skin.updateSkinBounds(bones);
			}
			skin = null;
		}
		
		override protected function calculate(collector:RenderCollector):void 
		{
			//スキン姿勢の逆行列の計算
			invertSkin.copyFrom(_worldMatrix);
			invertSkin.invert();
			
			var skin:Skin;
			for each (skin in skins) 
			{
				skin.updateBoneConstants(invertSkin);
			}
			skin = null;
		}
		
		/**
		 * スキン内にあるボーンオブジェクトを収集して必要なシェーダーを生成する
		 */
		public function collectBones():void
		{
			bones.length = 0;
			skins.length = 0;
			
			var current:Object3D;
			var bone:Bone;
			
			var task:Vector.<Object3D> = new <Object3D>[this];
			while (task.length)
			{
				current = task.pop()._children;
				while (current)
				{
					if (current is Skin)
					{
						skins.push(current as Skin);
					}
					bone = current as Bone;
					if (bone && bone.hasWeight)
					{
						bones.push(bone);
					}
					task.push(current);
					current = current._next;
				}
			}
			
			task = null;
			current = null;
			bone = null;
			
			var skin:Skin;
			for each (skin in skins) 
			{
				skin.createSkinShader(bones);
			}
			skin = null;
		}
		
		override public function finaly():void 
		{
			super.finaly();
			
			DataUtil.deleteVector(bones);
			DataUtil.deleteVector(skins);
			bones = null;
			skins = null;
			invertSkin = null;
		}
		
		override public function referenceProperties(target:Object3D):void
		{
			super.referenceProperties(target);
			
			var skin:SkinContainer = target as SkinContainer;
			//skin.rawBounds = rawBounds? rawBounds.clone() : null;
			skin = null;
		}
		
		override public function cloneProperties(target:Object3D):void 
		{
			super.cloneProperties(target);
			
			var skin:SkinContainer = target as SkinContainer;
			//skin.rawBounds = rawBounds? rawBounds.clone() : null;
			skin = null;
		}
		
		override public function clone():Object3D 
		{
			var result:SkinContainer = new SkinContainer();
			
			cloneProperties(result);
			
			//子を再帰的にコピーする
			var current:Object3D;
			for (current = _children; current; current = current._next)
			{
				result.addChild(current.clone());
			}
			
			result.collectBones();
			
			return result;
		}
		
		override public function reference():Object3D 
		{
			var result:SkinContainer = new SkinContainer();
			
			referenceProperties(result);
			
			//子を再帰的にコピーする
			var current:Object3D;
			for (current = _children; current; current = current._next)
			{
				result.addChild(current.reference());
			}
			
			result.collectBones();
			
			return result;
		}
		
	}

}
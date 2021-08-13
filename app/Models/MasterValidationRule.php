<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class MasterValidationRule extends Model
{
    protected $table='master_validation_rules';
    public $incrementing = true;

    protected $fillable = [
        'id', 'product_id','bank_id','param_name','param_value'
    ];

    function product() {
        return $this->belongsTo('App\Models\MasterProduct');
    }

    function bank() {
        return $this->belongsTo('App\Models\MasterBank');
    }
}

<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class MasterMapProductInsurance extends Model
{
    protected $table='master_map_product_insurances';

    public $incrementing = true;

    protected $fillable = [
        'id','product_id', 'insurance_kind_id'
    ];

    function product() {
        return $this->belongsTo('App\Models\MasterProduct','product_id','id');
    }

    function insurancekind() {
        return $this->belongsTo('App\Models\MasterInsuranceKind','insurance_kind_id','id');
    }
}
